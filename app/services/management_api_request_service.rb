require 'uri'
require 'securerandom'

class ManagementAPIv1Client
  def initialize(root_url, security_configuration)
    @root_api_url           = URI.parse(root_url + '/management_api/v1') # TODO: URL join.
    @security_configuration = security_configuration
  end

  def request(request_method, request_path, request_parameters, options = {})
    raise ArgumentError, "Request method is not supported: #{request_method.inspect}." unless request_method.in?(%i[post put])

    action     = @security_configuration[:actions].fetch(options[:action]) if options.key?(:action)
    keychain   = {}
    algorithms = {}

    @security_configuration[:keychain].each do |id, key|
      next unless action
      next unless id.in?(action[:required_signatures])
      keychain[id]   = key[:value]
      algorithms[id] = key[:algorithm]
    end

    payload = {
      data: request_parameters,
      iat:  Time.now.to_i,
      exp:  Time.now.to_i + 60, # TODO: Configure.
      jti:  SecureRandom.hex(12),
      iss:  'applogic' } # TODO: Configure.

    jwt = JWT::Multisig.generate_jwt(payload, keychain, algorithms)

    if action && action[:requires_barong_totp]
      #jwt = Barong::ManagementAPIv1Client.new.totp_sign(jwt)
      raise ArgumentError "Barong::ManagementAPIv1Client"
    end

    Faraday.public_send(request_method, @root_api_url.to_s + request_path, jwt.to_json, { # TODO: URL join.
      'Content-Type' => 'application/json',
      'Accept'       => 'application/json'
    }).assert_success!.yield_self { |response| JSON.parse(response.body) }
  end
end

class Peatio::ManagementAPIv1Client < ManagementAPIv1Client
  def initialize(*)
    super ENV.fetch('PEATIO_ROOT_URL'), Rails.configuration.x.peatio_management_api_v1_configuration
  end

  def create_withdraw(parameters = {})
    request(:post, '/withdraws/new', parameters, action: :write_withdraws)
  end
end
