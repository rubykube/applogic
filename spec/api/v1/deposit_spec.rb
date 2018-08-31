# frozen_string_literal: true

require 'rails_helper'

describe APIv1::Deposit, type: :request do
  let(:user) { create(:user, :level_3) }
  let(:token) { jwt_for(user) }

  before do
    set_security_configuration(:peatio, actions: peatio_actions)
  end
  let(:peatio_actions) do
    { write_deposits: { required_signatures: %i[applogic] } }
  end

  describe 'POST /api/v1/deposit' do
     before do
      stub_request(:post, "#{ENV.fetch('PEATIO_ROOT_URL')}/management_api/v1/deposits/new")
        .to_return(status: peatio_response.status,
                   body: peatio_response.body.to_json.to_s,
                   headers: {})
      stub_request(:get, "#{ENV.fetch('PEATIO_ROOT_URL')}/api/v2/currencies/btc")
          .to_return(status: peatio_coin_response.status,
                     body: peatio_coin_response.body.to_json.to_s,
                     headers: {})
      stub_request(:get, "#{ENV.fetch('PEATIO_ROOT_URL')}/api/v2/currencies/usd")
          .to_return(status: peatio_fiat_response.status,
                     body: peatio_fiat_response.body.to_json.to_s,
                     headers: {})
      stub_request(:get, "#{ENV.fetch('PEATIO_ROOT_URL')}/api/v2/currencies/foo")
          .to_return(status: peatio_unknown_currency_response.status,
                      body: peatio_unknown_currency_response.body.to_json.to_s,
                      headers: {})
    end
    let(:peatio_response) do
      OpenStruct.new(status: 200, body: { 'foo' => 'bar' })
    end
    let(:peatio_coin_response) do
      OpenStruct.new(status: 200, body: { 'type' => 'coin' })
    end
    let(:peatio_fiat_response) do
      OpenStruct.new(status: 200, body: { 'type' => 'fiat' })
    end
    let(:peatio_unknown_currency_response) do
      OpenStruct.new(status: 500, body: { error: { message: 'id does not have a valid value'}})
    end
    let(:do_request) do
      api_post '/api/v1/deposit', token: token, params: params
    end
    
    context 'coin deposit' do
      let(:params) do
        {
          currency: 'btc',
          amount: 0.1,
        }
      end
      it 'responds with error message' do
        do_request
        expect(response.status).to eq 404
        expect(json_body).to eq ({"error" => "Currency is not fiat"})
      end
    end

    context 'fiat deposit' do
      let(:params) do
        {
          currency: 'usd',
          amount: 10,
        } 
      end
      it 'sends deposit request to peatio' do
        do_request
        expect(response.status).to eq 201
        expect(json_body).to eq peatio_response.body
      end
    end

    context 'when peatio responds with errors' do
      let(:params) do
        {
          currency: 'usd',
          amount: -10,
        } 
      end
      let(:peatio_response) do
        OpenStruct.new(status: 422, body: { error: 'External services error'})
      end
      it 'responds with external services error message' do
        do_request
        expect(response.status).to eq 422
        expect(json_body).to eq JSON.parse(peatio_response.body.to_json)
      end
    end

    context 'deposit with wrong currency' do
      let(:params) do
        {
          currency: 'foo',
          amount: 10,
        }
      end
      let(:peatio_response) do
        OpenStruct.new(status: 500, body: { error: 'id does not have a valid value'})
      end
      it 'responds with error message' do
        do_request
        expect(response.status).to eq 500
        expect(json_body).to eq JSON.parse(peatio_response.body.to_json)
      end
    end
  end
end
