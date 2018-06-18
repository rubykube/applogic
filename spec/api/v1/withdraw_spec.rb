# frozen_string_literal: true

require 'rails_helper'

describe APIv1::Withdraw, type: :request do
  let(:user) { create(:user, :level_3) }
  let(:token) { jwt_for(user) }

  before do
    set_security_configuration(:peatio, actions: peatio_actions)
    set_security_configuration(:barong, actions: barong_actions)
  end
  let(:peatio_actions) do
    { write_withdraws: { required_signatures: %i[applogic] } }
  end
  let(:barong_actions) do
    { otp_sign: { required_signatures: %i[applogic] } }
  end

  describe 'POST /api/v1/withdraws' do
    before do
      stub_request(:post, "#{ENV.fetch('PEATIO_ROOT_URL')}/management_api/v1/withdraws/new")
        .to_return(status: peatio_response.status,
                   body: peatio_response.body.to_json.to_s,
                   headers: {})
      stub_request(:post, "#{ENV.fetch('BARONG_ROOT_URL')}/management_api/v1/otp/sign")
        .to_return(status: barong_response.status,
                   body: barong_response.body.to_json.to_s,
                   headers: {})
    end
    let(:peatio_response) do
      OpenStruct.new(status: 200, body: { 'foo' => 'bar' })
    end
    let(:barong_response) do
      OpenStruct.new(status: 200, body: { 'foo' => 'bar' })
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
        expect(json_body).to eq peatio_response.body
      end
    end

    context 'when action requires barong totp' do
      let(:peatio_actions) do
        {
          write_withdraws: {
            required_signatures: %i[applogic],
            requires_barong_totp: true
          }
        }
      end

      it 'sends withdrawal request to peatio and barong' do
        do_request
        expect(response.status).to eq 201
        expect(json_body).to eq peatio_response.body
      end
    end

    context 'when barong responds with errors' do
      before do
        stub_request(:post, "#{ENV.fetch('PEATIO_ROOT_URL')}/management_api/v1/withdraws/new")
          .to_raise(StandardError)
      end
      let(:barong_response) do
        OpenStruct.new(status: 422, body: { error: 'OTP code is invalid' })
      end
      let(:peatio_actions) do
        {
          write_withdraws: {
            required_signatures: %i[applogic],
            requires_barong_totp: true
          }
        }
      end

      it 'doesn\'t send request to peatio' do
        expect{ do_request }.to_not raise_error(StandardError)
      end

      it 'responds with barong error message' do
        do_request
        expect(response.status).to eq 422
        expect(json_body).to eq JSON.parse(barong_response.body.to_json)
      end
    end

    context 'when barong responds with internal server error' do
      before do
        stub_request(:post, "#{ENV.fetch('PEATIO_ROOT_URL')}/management_api/v1/withdraws/new")
          .to_raise(StandardError)
      end
      let(:barong_response) do
        OpenStruct.new(status: 500, body: { })
      end
      let(:peatio_actions) do
        {
          write_withdraws: {
            required_signatures: %i[applogic],
            requires_barong_totp: true
          }
        }
      end

      it 'doesn\'t send request to peatio' do
        expect{ do_request }.to_not raise_error(StandardError)
      end

      it 'responds with external services error message' do
        do_request
        expect(response.status).to eq 422
        expect(json_body).to eq({'error' => 'External services error'})
      end
    end
  end
end
