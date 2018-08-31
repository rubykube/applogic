# frozen_string_literal: true

module Peatio
  module ManagementAPIv1
    class Client < ::ManagementAPIv1::Client
      def initialize(*)
        super ENV.fetch('PEATIO_ROOT_URL'),
          Rails.configuration.x.peatio_management_api_v1_configuration
      end

      def create_withdraw(request_params = {})
        self.action = :write_withdraws
        # rubocop:disable Layout/MultilineMethodCallIndentation
        jwt = payload(request_params.slice(:uid, :tid, :rid, :currency, :amount, :action))
                .yield_self { |payload| generate_jwt(payload) }
                .yield_self do |token|
                  if action[:requires_barong_totp]
                    # rubocop:disable Metrics/LineLength
                    Barong::ManagementAPIv1::Client.new.otp_sign(request_params.merge(jwt: token, account_uid: request_params[:uid]))
                    # rubocop:enable Metrics/LineLength
                  else
                    token
                  end
                end
        # rubocop:enable Layout/MultilineMethodCallIndentation
        request(:post, 'withdraws/new', jwt, jwt: true)
      end
    end
  end
end
