# frozen_string_literal: true

class BaseAPI < Grape::API
  # Use endpoints of all available versions
  namespace :api do
    mount V1::Base
  end
end
