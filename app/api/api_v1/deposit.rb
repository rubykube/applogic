# frozen_string_literal: true

module APIv1
  class Deposit < Grape::API
    before { authenticate! }

    desc 'Request a deposit'
    params do
      requires :currency,
               type: String,
               desc: 'Any supported fiats currency: USD, EUR, etc.'
      requires :amount,
               type: BigDecimal,
               desc: 'Deposit amount.'
    end
    post '/deposit' do
      currency = Peatio::MemberAPIv2::Client.new.get_currency(params[:currency])
      if currency['type'] != 'fiat'
        error!('Currency is not fiat', 404)
      end

      Peatio::ManagementAPIv1::Client.new.create_deposit(
          uid:      env['api.v1.authenticated_uid'],
          currency: params[:currency],
          amount:   params[:amount],
      )
    end
  end
end