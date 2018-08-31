# frozen_string_literal: true

unless ENV['JWT_PUBLIC_KEY'].blank?
  key = OpenSSL::PKey.read(Base64.urlsafe_decode64(ENV['JWT_PUBLIC_KEY']))
  if key.private?
    raise ArgumentError, 'JWT_PUBLIC_KEY was set to private key, however it should be public.'
  end
  Rails.configuration.x.jwt_public_key = key
end
