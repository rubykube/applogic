# frozen_string_literal: true

require 'rails_helper'

describe APIv1::Withdraw, type: :request do
  let(:user) { create(:user, :level_3) }
  let(:token) { jwt_for(user) }
  let!(:beneficiary) { create(:beneficiary, uid: user.uid) }

  describe 'GET /api/v1/beneficiaries' do
    let(:do_request) { api_get '/api/v1/beneficiaries', token: token }

    it 'Return beneficiaries for current user' do
      do_request
      expect(response.status).to eq(200)
      expect(json_body.size).to eq(1)
      expect(json_body.first['rid']).to eq(beneficiary.rid)
    end
  end

  describe 'GET /api/v1/beneficiaries/rid' do
    let(:do_request) { api_get "/api/v1/beneficiaries/#{beneficiary.rid}", token: token }

    it 'Return beneficiary for current user' do
      do_request
      expect(response.status).to eq(200)
      expect(json_body['rid']).to eq(beneficiary.rid)
    end
  end

  describe 'POST /api/v1/beneficiaries' do
    let(:do_request) { api_post '/api/v1/beneficiaries', token: token, params: params }
    let(:beneficiary) { build :beneficiary }

    context 'when all required fields are provided' do
      let(:params) do
        beneficiary.attributes
      end

      it 'Create beneficiary for current user' do
        expect { do_request }.to change { Beneficiary.count }.by(1)
        expect(response.status).to eq(201)
        expect(json_body['uid']).to eq(user.uid)
      end
    end

    context 'when all params are missing' do
      let(:params) do
        {}
      end
      let(:errors) do
        ['full_name is missing',
         'address is missing',
         'country is missing',
         'currency is missing',
         'account_number is missing',
         'account_type is missing',
         'bank_name is missing',
         'bank_address is missing',
         'bank_country is missing'].join(', ')
      end

      it 'renders an error' do
        do_request
        expect(response.status).to eq(422)
        expect(json_body).to eq('error' => errors)
      end
    end
  end

  describe 'PATCH /api/v1/beneficiaries/rid' do
    let(:do_request) do
      api_patch "/api/v1/beneficiaries/#{beneficiary.rid}", token: token,
                                                            params: params
    end
    let(:params) do
      { full_name: 'Name' }
    end

    it 'Update beneficiary for current user' do
      expect { do_request }.to change { beneficiary.reload.full_name }.to('Name')
      expect(response.status).to eq(200)
      expect(json_body['uid']).to eq(user.uid)
    end
  end

  describe 'DELETE /api/v1/beneficiaries/rid' do
    let(:do_request) do
      api_delete "/api/v1/beneficiaries/#{beneficiary.rid}", token: token
    end

    it 'Delete beneficiary for current user' do
      do_request
      expect(response.status).to eq(204)
    end
  end
end
