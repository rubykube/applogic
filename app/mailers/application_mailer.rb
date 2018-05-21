# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('SENDER_EMAIL', 'noreply@rubykube.io')
  layout 'mailer'
end
