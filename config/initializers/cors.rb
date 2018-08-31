# frozen_string_literal: true

require 'grape/middleware/error'

module APIv1CORS
  def rack_response(*args)
    if env.fetch('REQUEST_URI').start_with?(%r{\A\/api\/v1\/})
      args << {} if args.count < 3
      APIv1::CORS.call(args[2])
    end
    super(*args)
  end
end

Grape::Middleware::Error.prepend APIv1CORS
