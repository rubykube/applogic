# frozen_string_literal: true

module Peatio
  class ManagementAPIv1Client < ::ManagementAPIv1Client
    def initialize(*)
      super ENV.fetch('PEATIO_ROOT_URL'), Rails.configuration.x.peatio_management_api_v1_configuration
    end

    def create_withdraw(request_params = {})
      action = :write_withdraws
      jwt = payload(request_params)
              .yield_self { |p| generate_jwt(p) }
              .yield_self { |j| action[:requires_barong_totp] ? Barong::ManagementAPIv1Client.new.otp_sign(request_params.merge(jwt: j)) : j}
      request(:post, '/withdraws/new', jwt, jwt: true)
    end
  end
end
