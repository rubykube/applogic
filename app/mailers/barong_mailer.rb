# frozen_string_literal: true

class BarongMailer < ApplicationMailer
  def verification_email(email, token)
    @token = token
    mail(to: email, subject: 'Account Verification')
  end
end
