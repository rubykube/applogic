# frozen_string_literal: true

require 'uri'
require 'securerandom'

class ManagementAPIv1Client
  extend Memoist

  def initialize(root_url, security_configuration)
    @root_api_url = URI.join(root_url, '/management_api/v1')
    @security_configuration = security_configuration
  end

  def request(request_method, request_path, request_parameters, options = {})
    options = { jwt: false }.merge(options)
    raise ArgumentError, "Request method is not supported: #{request_method.inspect}." unless request_method.in?(%i[post put])
    @action = @security_configuration[:actions].fetch(options[:action]) if options.key?(:action)

    request_parameters = generate_jwt(payload(request_parameters)) unless options[:jwt]

    Faraday.public_send(request_method, URI.join(@root_api_url.to_s + request_path).to_s, request_parameters.to_json, {
      'Content-Type' => 'application/json',
      'Accept'       => 'application/json'
    }).assert_success!.yield_self { |response| JSON.parse(response.body) }
  end

  def keychain(field)
    {}.tap do |h|
      @security_configuration[:keychain].each do |id, key|
        next unless @action
        next unless id.in?(@action[:required_signatures])
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
end

