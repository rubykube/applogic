# frozen_string_literal: true

module Frontend
  module V1
    class Base < Grape::API
      # Use Accept header to reach the specific version.
      # E.g. 'Accept:application/vnd.frontend-v1+json'.
      version 'v1', using: :header, vendor: 'frontend'
    end
  end
end
