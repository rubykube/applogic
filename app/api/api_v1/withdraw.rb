# frozen_string_literal: true

module APIv1
  class Withdraw < Grape::API
    before { authenticate! }

    desc 'Request a withdraw'
    params do
      requires :currency,
               type: String,
               desc: 'Any supported currency: USD, BTC, ETH.'
      requires :amount,
               type: BigDecimal,
               desc: 'Withdraw amount.'
      requires :otp,
               type: String,
               desc: 'Two-factor authentication code'
      requires :rid,
               type: String,
               desc: 'The beneficiary ID or wallet address on the Blockchain.'
    end
    post '/withdraws' do
      currency = Peatio::MemberAPIv2::Client.new.get_currency(params[:currency])
      if currency['type'] == 'fiat' &&
         !Beneficiary.active.where(uid: env['api.v1.authenticated_uid'], rid: params[:rid]).exists?
        error!('Beneficiary is not found', 422)
      end

      Peatio::ManagementAPIv1::Client.new.create_withdraw(
        uid:      env['api.v1.authenticated_uid'],
        currency: params[:currency],
        amount:   params[:amount],
        otp_code: params[:otp],
        rid:      params[:rid]
      )
    end
  end
end
