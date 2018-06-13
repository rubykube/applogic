# frozen_string_literal: true

module APIv1
  module ExceptionHandlers
    def self.included(base)
      base.instance_eval do
        rescue_from Grape::Exceptions::ValidationErrors do |e|
          error!({ error: { code: 1001, message: e.message } }, 422)
        end
      end
    end
  end

  class Error < Grape::Exceptions::Base
    attr_reader :code, :text

    # code: api error code defined by Peatio, errors originated from
    # subclasses of Error have code start from 2000.
    # text: human readable error message
    # status: http status code
    def initialize(opts = {})
      @code    = opts[:code]   || 2000
      @text    = opts[:text]   || ''

      @status  = opts[:status] || 400
      @message = { error: { code: @code, message: @text } }
    end

    def inspect
      message  = @text
      message += " (#{@reason})" if @reason.present?
      %(#<#{self.class.name}: #{message}>)
    end
  end

  class AuthorizationError < Error
    attr_reader :reason

    def initialize(reason = nil)
      @reason = reason
      super code: 2001, text: 'Authorization failed', status: 401
    end
  end
end
