# frozen_string_literal: true

module APITestHelpers
  extend Memoist

  def json_body
    JSON.parse(response.body)
  end

  def post_json(destination, body, headers = {})
    post destination,
         String === body ? body : body.to_json,
         headers.reverse_merge('Content-Type' => 'application/json')
  end

  def put_json(destination, body, headers = {})
    put destination,
        String === body ? body : body.to_json,
        headers.reverse_merge('Content-Type' => 'application/json')
  end

  def api_request(method, url, options = {})
    headers = options.fetch(:headers, {})
    params  = options.fetch(:params, {})
    options[:token].tap { |t| headers['Authorization'] = 'Bearer ' + t if t }
    public_send(method, url, params: params, headers: headers)
  end

  def api_get(*args)
    api_request(:get, *args)
  end

  def api_post(*args)
    api_request(:post, *args)
  end

  def api_delete(*args)
    api_request(:delete, *args)
  end

  #
  # Generates valid JWT for user, allows to pass additional payload.
  #
  def jwt_for(user, payload = { x: 'x', y: 'y', z: 'z' })
    jwt_build(payload.merge(uid: user.uid))
  end

  #
  # Generates valid JWT. Accepts payload as argument. Add fields required for JWT to be valid.
  #
  def jwt_build(payload)
    jwt_encode payload.reverse_merge \
      iat: Time.now.to_i,
      exp: 20.minutes.from_now.to_i,
      jti: SecureRandom.uuid,
      sub: 'session',
      iss: 'someone',
      aud: ['barong']
  end

  #
  # Generates JWT token based on payload. Doesn't add any extra fields to payload.
  #
  def jwt_encode(payload)
    OpenSSL::PKey.read(Base64.urlsafe_decode64(jwt_keypair_encoded[:private])).yield_self do |key|
      JWT.encode(payload, key, ENV.fetch('JWT_ALGORITHM'))
    end
  end

  def jwt_keypair_encoded
    require 'openssl'
    require 'base64'
    OpenSSL::PKey::RSA.generate(2048).yield_self do |p|
      Rails.configuration.x.jwt_public_key = p.public_key
      { public:  Base64.urlsafe_encode64(p.public_key.to_pem),
        private: Base64.urlsafe_encode64(p.to_pem) }
    end
  end
  memoize :jwt_keypair_encoded

  def multisig_jwt(payload, keychain, signers, algorithms)
    JWT::Multisig.generate_jwt(payload, keychain.slice(*signers), algorithms)
  end

  def multisig_jwt_management_api_v1(payload, *signers)
    multisig_jwt(payload, management_api_v1_keychain, signers, management_api_v1_algorithms)
  end

  def set_security_configuration(application, actions:, version: 'v1')
    config = { jwt: {} }
    config[:keychain] = management_api_v1_keychain.each_with_object({}) do |(signer, key), memo|
      memo[signer] = { algorithm: management_api_v1_algorithms.fetch(signer), value: key }
    end
    config[:actions] = actions

    config_key = "#{application}_management_api_#{version}_configuration="
    Rails.configuration.x.public_send config_key, config.merge(action)
  end

  def management_api_v1_keychain
    {
      applogic:  OpenSSL::PKey::RSA.generate(2048)
    }
  end
  memoize :management_api_v1_keychain

  def management_api_v1_algorithms
    management_api_v1_keychain.each_with_object({}) { |(k, _v), memo| memo[k] = 'RS256' }
  end
  memoize :management_api_v1_algorithms
end

RSpec.configure { |config| config.include APITestHelpers }
