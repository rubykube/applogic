# frozen_string_literal: true

module Peatio
  module Model
    class DepositUpdatedConsumer
      def call(event)
        record = event.dig(:record)
        user = User.find_by(uid: record[:uid])
        transaction = OpenStruct.new(
          id: record[:tid],
          user_id: user.uid,
          amount_currency: record[:currency],
          amount: record[:amount],
          created_at: record[:created_at]
        )
        DepositMailer.confirmation_email(transaction).deliver_now
      end

      class << self
        def call(event)
          new.call(event)
        end
      end
    end
  end
end
