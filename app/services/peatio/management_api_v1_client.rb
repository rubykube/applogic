# frozen_string_literal: true

module Peatio
  class ManagementAPIv1Client < ::ManagementAPIv1Client
    def initialize(*)
      super ENV.fetch('PEATIO_ROOT_URL'), Rails.configuration.x.peatio_management_api_v1_configuration
    end

    def create_withdraw(request_params = {})
      @action = @security_configuration[:actions].fetch(:write_withdraws)
      jwt = payload(request_params.slice(:uid, :tid, :rid, :currency, :amount, :action))
              .yield_self { |payload| generate_jwt(payload) }
              .yield_self do |jwt|
                @action[:requires_barong_totp] ? Barong::ManagementAPIv1Client.new.otp_sign(request_params.merge(jwt: jwt)) : jwt
              end
      request(:post, '/withdraws/new', jwt, jwt: true, action: :write_withdraws)
    end
  end
end
