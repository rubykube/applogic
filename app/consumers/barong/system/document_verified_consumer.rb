# frozen_string_literal: true

module Barong
  module System
    class DocumentVerifiedConsumer
      def call(event)
        email = event.fetch(:email)
        ProfileMailer.documents_verified(email).deliver_now
      end

      class << self
        def call(event)
          new.call(event)
        end
      end
    end
  end
end
