# frozen_string_literal: true

module APIv1
  module Helpers
    extend Memoist

    def authenticate!
      current_user || raise(AuthorizationError)
    end

    def current_user
      key = 'api.v1.authenticated_uid' # JWT authentication provides user uid.
      return unless env.key?(key)

      User.find_by(uid: env[key])
    end
    memoize :current_user
  end
end
