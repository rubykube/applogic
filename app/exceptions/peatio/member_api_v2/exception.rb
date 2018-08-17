# frozen_string_literal: true

module Peatio
  module MemberAPIv2
    class Exception < StandardError
      attr_accessor :status

      def initialize(response_or_ex = 'External services error')
        @status = 503
        if response_or_ex.respond_to?(:body)
          @status = 422 unless response_or_ex.server_error?
          super response_or_ex.body.dig('error', 'message') || 'External service error'
        else
          super response_or_ex
        end
      end
    end
  end
end
