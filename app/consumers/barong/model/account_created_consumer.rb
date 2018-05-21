# frozen_string_literal: true

module Barong
  module Model
    class AccountCreatedConsumer
      def call(event)
        token = event[:record][:confirmation_token]
        email = event[:record][:email]
        BarongMailer.verification_email(email, token).deliver_now
      end

      class << self
        def call(event)
          new.call(event)
        end
      end
    end
  end
end
