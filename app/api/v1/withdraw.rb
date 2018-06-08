# frozen_string_literal: true

module V1
  class Withdraw < Grape::API
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
    end
  end
end
