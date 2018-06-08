# frozen_string_literal: true

module V2
  class Base < Grape::API
    # Use Accept header to reach the specific version.
    # E.g. 'Accept:application/vnd.frontend-v2+json'.
    version 'v2', using: :header, vendor: 'frontend'
  end
end
