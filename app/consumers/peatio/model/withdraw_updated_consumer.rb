# frozen_string_literal: true

module Peatio
  module Model
    class WithdrawUpdatedConsumer
      def call(event)
        record = event.dig(:record)
        transaction = OpenStruct.new(
          email: record[:email],
          id: record[:tid],
          address: record[:rid],
          amount_currency: record[:currency],
          amount: record[:amount],
          fee: record[:fee],
          created_at: record[:created_at]
        )
        WithdrawalMailer.confirmation_email(transaction).deliver_now
      end

      class << self
        def call(event)
          new.call(event)
        end
      end
    end
  end
end
