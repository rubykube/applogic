# frozen_string_literal: true

module Barong
  module System
    class AccountResetPasswordTokenConsumer
      def call(event)
        email = event.fetch(:email)
        token = event.fetch(:token)
        AccountMailer.password_reset_email(email, token).deliver_now
      end

      class << self
        def call(event)
          new.call(event)
        end
      end
    end
  end
end
