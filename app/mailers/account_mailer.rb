# frozen_string_literal: true

class AccountMailer < ApplicationMailer
  def verification_email(email, token)
    @email = email
    @confirmation_link =
      ENV.fetch('BARONG_ACCOUNT_EMAIL_CONFIRMATION_URL_TEMPLATE').gsub(/#\{token\}/, token)

    mail(to: @email, subject: 'Account email confirmation instructions')
  end

  def password_reset_email(email, token)
    @email = email
    @password_reset_link =
      ENV.fetch('BARONG_ACCOUNT_PASSWORD_RESET_URL_TEMPLATE').gsub(/#\{token\}/, token)

    mail(to: @email, subject: 'Reset password instructions')
  end

  def unlock_instructions(email, token)
    @email = email
    @unlock_link = ENV.fetch('BARONG_ACCOUNT_UNLOCK_URL_TEMPLATE').gsub(/#\{token\}/, token)

    mail(to: @email, subject: 'Reset password instructions')
  end
end
