# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  def order_created(email, event)
    @email = email
    @order = event

    mail(to: @email, subject: 'New order created')
  end
end
