# frozen_string_literal: true

class BarongMailer < ApplicationMailer
  def verification_email(email, token)
    @email = email
    @confirmation_link = ENV.fetch('EMAIL_CONFIRMATION_URL_TEMPLATE').gsub('#{token}', token)
    mail(to: @email, subject: 'Account email confirmation instructions')
  end
end
