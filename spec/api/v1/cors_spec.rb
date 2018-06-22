# frozen_string_literal: true

require 'rails_helper'

describe APIv1::Withdraw, type: :request do
  let(:user) { create(:user, :level_3) }
  let(:token) { jwt_for(user) }

  def check_cors(response)
    expect(response.headers['Access-Control-Allow-Origin']).to eq('https://peatio.tech')
    expect(response.headers['Access-Control-Allow-Methods']).to eq('GET, POST, PUT, PATCH, DELETE')
    expect(response.headers['Access-Control-Allow-Headers']).to eq('Origin, X-Requested-With, Content-Type, Accept, Authorization')
    expect(response.headers['Access-Control-Allow-Credentials']).to eq('false')
  end

  before { ENV['API_CORS_ORIGINS'] = 'https://peatio.tech' }

  it 'sends CORS headers when requesting using OPTIONS' do
    reset! unless integration_session
    integration_session.send :process, 'OPTIONS', '/api/v1/withdraws'
    expect(response).to be_successful
    check_cors(response)
  end

  it 'sends CORS headers ever when user is not authenticated' do
    api_post '/api/v1/withdraws'
    expect(response).to have_http_status 401
    check_cors(response)
  end

  it 'sends CORS headers when invalid parameter supplied' do
    api_post '/api/v1/withdraws', token: token, params: { currency: 'uah' }
    expect(response).to have_http_status 422
    check_cors(response)
  end
end
