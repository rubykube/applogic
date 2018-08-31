# frozen_string_literal: true

module ManagementAPIv1
  class ExceptionsMiddleware < Faraday::Middleware
    def call(request_env)
      @app.call(request_env)
    rescue Faraday::Error
      raise ManagementAPIv1Exception
    end
  end
end
