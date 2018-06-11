# frozen_string_literal: true

class BaseAPI < Grape::API
  cascade false

  format         :json
  content_type   :json, 'application/json'
  default_format :json

  do_not_route_options!

  # rescue_from(BaseAPI::V1::Exceptions::Base) { |e| error!(e.message, e.status, e.headers) }
  rescue_from(Grape::Exceptions::ValidationErrors) { |e| error!(e.message, 422) }
  rescue_from(ActiveRecord::RecordNotFound) { error!('Record is not found', 404) }

  # use BaseAPI::V1::JWTAuthenticationMiddleware

  mount V1::Base

  add_swagger_documentation base_path: '/api',
                            info: {
                              title: 'API v1',
                              description: 'API is client-to-server API'
                            },
                            api_version: 'v1',
                            doc_version: '0.0.1',
                            hide_format: true,
                            hide_documentation_path: true,
                            mount_path: '/swagger_doc'

  route :any, '*path' do
    raise StandardError, 'Unable to find endpoint'
  end
end
