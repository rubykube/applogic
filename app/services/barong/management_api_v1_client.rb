# frozen_string_literal: true

module Barong
  class ManagementAPIv1Client < ::ManagementAPIv1Client
    def initialize(*)
      super ENV.fetch('BARONG_ROOT_URL'), Rails.configuration.x.barong_management_api_v1_configuration
    end

    def otp_sign(request_params = {})
      self.action = :otp_sign
      params = request_params.slice(:account_uid, :otp_code, :jwt)
      request(:post, 'otp/sign', params)
    end
  end
end
