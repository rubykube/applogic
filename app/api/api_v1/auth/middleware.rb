# frozen_string_literal: true

module APIv1
  module Auth
    class Middleware < Grape::Middleware::Base
      def before
        return unless auth_by_jwt?

        env['api.v1.authenticated_data'] = \
          JWTAuthenticator.new(headers['Authorization']).authenticate!
      end

      private

      def auth_by_jwt?
        headers.key?('Authorization')
      end

      def request
        @request ||= Grape::Request.new(env)
      end

      def params
        request.params
      end

      def headers
        request.headers
      end
    end
  end
end
