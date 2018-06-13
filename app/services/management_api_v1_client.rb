# frozen_string_literal: true

require 'securerandom'

class ManagementAPIv1Client
  extend Memoist

  attr_reader :action

  def initialize(root_url, security_configuration)
    @root_api_url = root_url
    @security_configuration = security_configuration
  end

  def request(request_method, request_path, request_parameters, options = {})
    options = { jwt: false }.merge(options)
    unless request_method.in?(%i[post put])
      raise ArgumentError, "Request method is not supported: #{request_method.inspect}."
    end

    request_parameters = generate_jwt(payload(request_parameters)) unless options[:jwt]

    http_client
      .public_send(request_method, build_path(request_path), request_parameters)
      .assert_success!
      .yield_self(&:body)
  end

  def build_path(path)
    "management_api/v1/#{path}"
  end

  def http_client
    Faraday.new(url: @root_api_url) do |conn|
      conn.request :json
      conn.response :json
      conn.response :logger if ENV['HTTP_LOGGER']
      conn.adapter Faraday.default_adapter
    end
  end
  memoize :http_client

  def keychain(field)
    {}.tap do |h|
      @security_configuration[:keychain].each do |id, key|
        next unless action
        next unless id.in?(action[:required_signatures])
        h[id] = key[field]
      end
    end
  end
  memoize :keychain

  def payload(data)
    {
      data: data,
      iat:  Time.now.to_i,
      exp:  Time.now.to_i + 60, # TODO: Configure.
      jti:  SecureRandom.hex(12),
      iss:  'applogic'
    } # TODO: Configure.
  end

  def generate_jwt(payload)
    JWT::Multisig.generate_jwt(payload, keychain(:value), keychain(:algorithm))
  end

  def action=(value)
    @action = @security_configuration[:actions].fetch(value)
  end
end
