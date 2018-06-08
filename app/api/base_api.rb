# frozen_string_literal: true

class BaseAPI < Grape::API
  prefix 'api'
  format :json

  # Use endpoints of all available versions
  mount V1::Base
end
