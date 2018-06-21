# frozen_string_literal: true

class DepositMailer < ApplicationMailer
  def confirmation_email(deposit)
    @transaction = deposit
    mail(to: @transaction.email, subject: 'Deposit Confirmation')
  end
end
