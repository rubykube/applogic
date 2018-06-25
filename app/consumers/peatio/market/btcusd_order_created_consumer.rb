# frozen_string_literal: true

module Peatio
  module Market
    class BtcusdOrderCreatedConsumer
      def call(event)
        uid = event.fetch(:trader_uid)
        account = Barong::ManagementAPIv1Client.new.read_accounts(uid: uid)
        OrderMailer.order_created(account['email'], event).deliver_now
      end

      class << self
        def call(event)
          new.call(event)
        end
      end
    end
  end
end
