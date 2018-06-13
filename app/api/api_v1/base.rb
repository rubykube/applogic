# frozen_string_literal: true

require_dependency 'api_v1/errors'

module APIv1
  class Base < Grape::API
    version 'v1', using: :path

    helpers APIv1::Helpers

    use APIv1::CORS::Middleware
    use APIv1::Auth::Middleware

    mount APIv1::Withdraw

    add_swagger_documentation base_path: BaseAPI::PREFIX,
                              mount_path: '/swagger',
                              api_version: 'v1',
                              doc_version: '0.0.1',
                              info: {
                                title: 'User API V1',
                                description: 'User API is client-to-server API'
                              },
                              hide_format: true,
                              hide_documentation_path: true
  end
end
