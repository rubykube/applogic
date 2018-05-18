# frozen_string_literal: true

task event_api_listener: :environment do
  Rails.logger = ActiveSupport::Logger.new(STDOUT, level: :debug)
  EventAPIListener.call \
    ENV.fetch('EVENT_API_APPLICATION'),
    ENV.fetch('EVENT_API_EVENT_CATEGORY'),
    ENV.fetch('EVENT_API_EVENT_NAME')
end
