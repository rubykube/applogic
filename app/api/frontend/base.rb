# frozen_string_literal: true

module Frontend
  class Base < Grape::API
    # Prefix will be added in a route after /api
    prefix 'frontend'

    # Use endpoints of all available versions
    # Use Accept header to reach the specific version.
    # E.g. Accept:application/vnd.frontend-v1+json
    mount Frontend::V1::Base
    mount Frontend::V2::Base
  end
end
