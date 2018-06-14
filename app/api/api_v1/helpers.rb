# frozen_string_literal: true

module APIv1
  module Helpers
    extend Memoist

    def authenticate!
      current_uid || raise(AuthorizationError)
    end

    def current_uid
      key = 'api.v1.authenticated_data' # JWT authentication provides user uid.
      return unless env.key?(key)

      env[key][:uid]
    end
    memoize :current_uid
  end
end
