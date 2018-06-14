# frozen_string_literal: true

module Faraday
  class Env
    attr_reader :request_body
  end

  class Connection
    alias original_run_request run_request

    def run_request(method, url, body, headers, &block)
      original_run_request(method, url, body, headers, &block).tap do |response|
        response.env.instance_variable_set :@request_body, body if body
      end
    end
  end

  class Response
    def assert_success!
      self.tap do |r|
        Rails.logger.debug { describe } unless r.success?
      end
    end

    def describe
      ["-- HTTP #{status} #{reason_phrase} --",
       '',
       '-- Request URL --',
       env.url.to_s,
       '',
       '-- Request Method --',
       env.method.to_s.upcase,
       '',
       '-- Request headers --',
       env.request_headers.to_json,
       '',
       '-- Request body --',
       env.request_body,
       '',
       '-- Response headers --',
       env.response_headers.to_json,
       '',
       '-- Response body --',
       env.body,
       ''
     ].join("\n")
    end
  end
end
