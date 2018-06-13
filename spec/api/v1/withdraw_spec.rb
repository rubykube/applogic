# frozen_string_literal: true

require 'rails_helper'

describe APIv1::Withdraw, type: :request do
  let(:user) { create(:user, :level_3) }
  let(:token) { jwt_for(user) }

  before do
    set_security_configuration(:peatio, actions: action)
  end
  let(:action) do
    { write_withdraws: { required_signatures: %i[applogic] } }
  end

  describe 'POST /api/v1/withdraws' do
    before do
      stub_request(:post, 'http://peatio/management_api/v1/withdraws/new')
        .to_return(status: 200, body: peatio_response.to_json.to_s, headers: {})
      stub_request(:post, 'http://barong/management_api/v1/otp_sign')
        .to_return(status: 200, body: barong_response.to_json.to_s, headers: {})
    end
    let(:peatio_response) do
      { 'foo' => 'bar' }
    end
    let(:barong_response) do
      { 'foo' => 'bar' }
    end

    let(:do_request) do
      api_post '/api/v1/withdraws', token: token, params: params
    end
    let(:params) do
      {
        currency: 'BTC',
        amount: 0.2,
        otp: '1234',
        rid: '123'
      }
    end

    context 'when action does not require barong totp' do
      it 'sends withdrawal request to peatio' do
        do_request
        expect(response.status).to eq 201
        expect(json_body).to eq peatio_response
      end
    end

    context 'when action requires barong totp' do
      it 'sends withdrawal request to peatio and barong' do
        do_request
        expect(response.status).to eq 201
        expect(json_body).to eq peatio_response
      end
    end
  end
end
