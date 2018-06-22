# frozen_string_literal: true

class ProfileMailer < ApplicationMailer
  def documents_verified(email)
    @email = email

    mail(to: @email, subject: 'Your identity was approved')
  end

  def documents_rejected(email)
    @email = email

    mail(to: @email, subject: 'Your identity was rejected')
  end
end
