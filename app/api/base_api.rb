# frozen_string_literal: true

class BaseAPI < Grape::API
  # Use endpoints of all available versions
  # Use Accept header to reach the specific version.
  # E.g. Accept:application/vnd.frontend-v1+json
  namespace :api do
    mount V1::Base
    mount V2::Base
  end
end
