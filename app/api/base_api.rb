# frozen_string_literal: true

class BaseAPI < Grape::API
  PREFIX = '/api'

  cascade false

  format         :json
  content_type   :json, 'application/json'
  default_format :json

  do_not_route_options!

  logger Rails.logger.dup
  logger.formatter = GrapeLogging::Formatters::Rails.new
  use GrapeLogging::Middleware::RequestLogger,
      logger:    logger,
      log_level: :info,
      include:   [GrapeLogging::Loggers::Response.new,
                  GrapeLogging::Loggers::FilterParameters.new,
                  GrapeLogging::Loggers::ClientEnv.new,
                  GrapeLogging::Loggers::RequestHeaders.new]

  rescue_from(Grape::Exceptions::ValidationErrors) { |e| error!(e.message, 422) }
  rescue_from(ActiveRecord::RecordNotFound) { error!('Record is not found', 404) }
  rescue_from(ManagementAPIv1Exception) {|e| error!(e.message, 422)}

  mount APIv1::Base

  route :any, '*path' do
    raise StandardError, 'Unable to find endpoint'
  end
end
