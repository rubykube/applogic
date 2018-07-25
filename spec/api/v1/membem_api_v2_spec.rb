# frozen_string_literal: true

require 'rails_helper'

describe APIv1::Withdraw, type: :request do

  describe 'Module Peatio::MemberAPIv2::Client' do
    before do
      stub_request(:get, "#{ENV.fetch('PEATIO_ROOT_URL')}/api/v2/currencies/btc")
          .to_return(status: peatio_coin_response.status,
                     body: peatio_coin_response.body.to_json.to_s,
                     headers: {})
      stub_request(:get, "#{ENV.fetch('PEATIO_ROOT_URL')}/api/v2/currencies/usd")
          .to_return(status: peatio_fiat_response.status,
                     body: peatio_fiat_response.body.to_json,
                     headers: {})
    end


    let(:peatio_coin_response) do
      OpenStruct.new(status: 200, body: { id: 'btc', symbol: '$', type: 'coin', deposit_fee: '0.0',
                                          withdraw_fee: '0.0', quick_withdraw_limit: '1000.0',
                                          base_factor: '100000000', precision: '8',
                                          allow_multiple_deposit_addresses: 'null' })
    end
    let(:peatio_fiat_response) do
      OpenStruct.new(status: 200, body: { id: 'usd', symbol: '$', type: 'fiat', deposit_fee: '0.0',
                                          withdraw_fee: '0.0', quick_withdraw_limit: '1000.0',
                                          base_factor: '1', precision: '8' })
    end


    context 'fiat' do
      let(:currency) do
        {
          'id' => 'usd', 'symbol' => '$', 'type' => 'fiat', 'deposit_fee' => '0.0',
          'withdraw_fee' => '0.0', 'quick_withdraw_limit' => '1000.0',
          'base_factor' => '1', 'precision' => '8'
        }
      end

      it 'send request with fiat' do
        expect(Peatio::MemberAPIv2::Client.new.get_currency(currency['id'])).to eq currency
      end
    end

    context 'cryptocurrency' do
      let(:currency) do
        {
          'id' => 'btc', 'symbol' => '$', 'type' => 'coin', 'deposit_fee' => '0.0',
          'withdraw_fee' => '0.0', 'quick_withdraw_limit' => '1000.0',
          'base_factor' => '100000000', 'precision' => '8',
          'allow_multiple_deposit_addresses' => 'null'
        }
      end

      it 'send request with cryptocurrency' do
        expect(Peatio::MemberAPIv2::Client.new.get_currency(currency['id'])).to eq currency
      end
    end
  end
end
