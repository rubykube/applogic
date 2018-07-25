module Peatio
  module MemberAPIv2
    class Client

      def initialize()
        @root_api_url = ENV.fetch('PEATIO_ROOT_URL')
      end

      def get_currency(currency)
        request(:get, "currencies/#{currency}")
      end

      private

      def request(request_method, request_path)
        unless request_method.in?(%i[get])
          raise ArgumentError, "Request method is not supported: #{request_method.inspect}."
        end

        begin
          http_client
              .public_send(request_method, build_path(request_path))
              .tap { |response| raise Peatio::MemberAPIv2::Exception, response unless response.success? }
              .assert_success!
              .body
        rescue Faraday::Error
          raise ManagementAPIv1::Exception
        end
      end

      def http_client
        Faraday.new(url: @root_api_url) do |conn|
          conn.request :json
          conn.response :json
          conn.adapter Faraday.default_adapter
        end
      end

      def build_path(path)
        "api/v2/#{path}"
      end
    end
  end
end
