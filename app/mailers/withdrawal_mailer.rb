# frozen_string_literal: true

class WithdrawalMailer < ApplicationMailer
  def confirmation_email(withdrawal)
    @transaction = withdrawal
    mail(to: @transaction.email, subject: 'Withdrawal Confirmation')
  end
end
