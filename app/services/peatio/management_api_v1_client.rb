# frozen_string_literal: true

module Peatio
  class ManagementAPIv1Client < ::ManagementAPIv1Client
    def initialize(*)
      super ENV.fetch('PEATIO_ROOT_URL'), Rails.configuration.x.peatio_management_api_v1_configuration
    end

    def create_withdraw(request_params = {})
      request(:post, '/withdraws/new', request_params, action: :write_withdraws)
    end
  end
end
