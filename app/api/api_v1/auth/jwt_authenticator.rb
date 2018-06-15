# frozen_string_literal: true

module APIv1
  module Auth
    class JWTAuthenticator
      def initialize(token)
        @token_type, @token_value = token.to_s.split(' ')
      end

      #
      # Decodes and verifies JWT.
      # Returns hash formed with payload including user id (uid) or raises an exception.
      #
      # @return [Hash, NilClass]
      def authenticate!
        check_token_type
        payload, _header = decode_and_verify_token(@token_value)

        { uid: fetch_uid(payload) }
      rescue => e
        report_exception(e)
        if AuthorizationError === e
          raise e
        else
          raise AuthorizationError, e.inspect
        end
      end

      #
      # Exception-safe version of #authenticate!.
      #
      # @return [Hash, NilClass]
      def authenticate
        authenticate!
      rescue
        nil
      end

      private

      def check_token_type
        unless @token_type == 'Bearer'
          raise AuthorizationError, 'Token type is not provided or invalid.'
        end
      end

      def decode_and_verify_token(token)
        JWT.decode(token, Utils.jwt_public_key, true, token_verification_options)
           .tap { |pair| pair[0].symbolize_keys! }
      rescue JWT::DecodeError => e
        raise AuthorizationError, "Failed to decode and verify JWT: #{e.inspect}."
      end

      def fetch_uid(payload)
        payload.fetch(:uid).tap do |uid|
          raise(AuthorizationError, 'UID is blank.') if uid.blank?
        end
      end

      def token_verification_options
        { verify_expiration: true,
          verify_not_before: true,
                             # Set option only if it is not blank.
          iss:               ENV['JWT_ISSUER'].to_s.squish.presence,
          verify_iss:        ENV['JWT_ISSUER'].present?,
          verify_iat:        true,
          verify_jti:        true,
                             # Support comma-separated JWT_AUDIENCE variable.
                             # We are rejecting blank values from the list here.
          aud:               ENV['JWT_AUDIENCE'].to_s.split(',').map(&:squish).reject(&:blank?).presence,
          verify_aud:        ENV['JWT_AUDIENCE'].present?,
          sub:               'session',
          verify_sub:        true,
          algorithms:        [ENV.fetch('JWT_ALGORITHM')],
          leeway:            ENV['JWT_DEFAULT_LEEWAY'].to_s.squish.yield_self { |n| n.to_i if n.present? },
          iat_leeway:        ENV['JWT_ISSUED_AT_LEEWAY'].to_s.squish.yield_self { |n| n.to_i if n.present? },
          exp_leeway:        ENV['JWT_EXPIRATION_LEEWAY'].to_s.squish.yield_self { |n| n.to_i if n.present? },
          nbf_leeway:        ENV['JWT_NOT_BEFORE_LEEWAY'].to_s.squish.yield_self { |n| n.to_i if n.present? }
        }.compact
      end
    end
  end
end
