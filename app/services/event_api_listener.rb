# frozen_string_literal: true

require 'bunny'

class EventAPIListener
  extend Memoist

  def initialize(application, event_category, event_name)
    @application    = application
    @event_category = event_category
    @event_name     = event_name
    Kernel.at_exit { unlisten }
  end

  def call
    consumer # Eager load consumer to early detect errors.
    listen
  end

  private

  def event_api_jwt_env(suffix)
    ENV["#{@application.upcase}_EVENT_API_JWT_#{suffix}"]
  end

  def event_api_jwt_env_to_int(suffix)
    event_api_jwt_env(suffix).to_s.squish.yield_self { |n| n.to_i if n.present? }
  end

  def listen
    unlisten
    @bunny_session = Bunny::Session.new(rabbitmq_credentials).tap(&:start)
    @bunny_channel = @bunny_session.channel
    exchange_name = [@application, 'events', @event_category].join('.')
    exchange      = @bunny_channel.direct(exchange_name)
    queue         = @bunny_channel.queue('', auto_delete: true, durable: true)
                                  .bind(exchange, routing_key: @event_name)
    Rails.logger.info { "Listening for #{exchange_name}.#{@event_name}." }
    queue.subscribe(block: true, &method(:handle_message))
  end

  def unlisten
    Rails.logger.info { 'No longer listening for events.' } if @bunny_session || @bunny_channel
    @bunny_channel&.work_pool&.kill
    @bunny_session&.stop
  ensure
    @bunny_channel = nil
    @bunny_session = nil
  end

  def jwt_public_key
    pem = Base64.urlsafe_decode64(event_api_jwt_env('PUBLIC_KEY'))
    OpenSSL::PKey.read(pem)
  end
  memoize :jwt_public_key

  def token_verification_options
    # We set option only if it is not blank.
    { verify_jti: true,
      iss:        event_api_jwt_env('ISSUER').to_s.squish.presence,
      verify_iss: event_api_jwt_env('ISSUER').present?,
      aud:        event_api_jwt_env('AUDIENCE').to_s.squish.presence,
      verify_aud: event_api_jwt_env('AUDIENCE').present?,
      sub:        event_api_jwt_env('SUBJECT'),
      verify_sub: event_api_jwt_env('SUBJECT').present? }
  end

  def algorithm_verification_options
    { algorithms: [ENV.fetch("#{@application.upcase}_EVENT_API_JWT_ALGORITHM")] }
  end

  def timing_verification_options
    { verify_expiration: true, verify_not_before: true, verify_iat: true,
      leeway:     event_api_jwt_env_to_int('DEFAULT_LEEWAY'),
      iat_leeway: event_api_jwt_env_to_int('ISSUED_AT_LEEWAY'),
      exp_leeway: event_api_jwt_env_to_int('EXPIRATION_LEEWAY'),
      nbf_leeway: event_api_jwt_env_to_int('NOT_BEFORE_LEEWAY') }
  end

  def rabbitmq_credentials
    @application.upcase.yield_self do |_app|
      if ENV['EVENT_API_RABBITMQ_URL'].present?
        ENV['EVENT_API_RABBITMQ_URL']
      else
        { host:     ENV.fetch('EVENT_API_RABBITMQ_HOST'),
          port:     ENV.fetch('EVENT_API_RABBITMQ_PORT'),
          username: ENV.fetch('EVENT_API_RABBITMQ_USERNAME'),
          password: ENV.fetch('EVENT_API_RABBITMQ_PASSWORD') }
      end
    end
  end

  def handle_message(_delivery_info, _metadata, payload)
    result = verify_jwt(payload)
    raise "Failed to verify signature from #{@application}." \
      unless result[:verified].include?(@application.to_sym)
    consumer.call(result[:payload].fetch(:event))
  rescue StandardError => e
    Rails.logger.error { e.inspect }
  end

  def consumer
    [@application, @event_category, @event_name.tr('.', '_') + '_consumer']
      .map { |x| x.tr('.', '_') }
      .join('/')
      .camelize
      .constantize
  end
  memoize :consumer

  def verify_jwt(payload)
    options = token_verification_options.merge(timing_verification_options)
                                        .merge(algorithm_verification_options)
    JWT::Multisig.verify_jwt JSON.parse(payload), { @application.to_sym => jwt_public_key },
                             options.compact
  end

  class << self
    def call(*args)
      new(*args).call
    end
  end
end
