# frozen_string_literal: true

describe 'POST api/v1/withdrawals' do
  it 'works' do
    user_api_jwt = jwt_build(
      uid: 'ID1F467E2B9E',
      email: 'syber-junkie@example.com',
      aud: %w[applogic barong peatio]
    )

    headers = {
      'Accept'        => 'application/json',
      'Authorization' => "Bearer #{user_api_jwt}",
      'HTTP_ORIGIN'   => 'example.com'
    }

    params = {
      currency: 'BTC',
      amount: '0.01',
      otp: '245924',
      rid: '0xb111'
    }
    VCR.use_cassette('happy-path') do
      post '/api/v1/withdrawals', params: params, headers: headers
    end
    expect(response).to have_http_status(:created)
  end

  it 'throws error if OTP code is wrong' do
    pending 'Currently config/initializers/faraday.rb raises Faraday::Error but should return normal response'
    user_api_jwt = jwt_build(
      uid: 'ID1F467E2B9E',
      email: 'syber-junkie@example.com',
      aud: %w[applogic barong peatio]
    )

    headers = {
      'Accept'        => 'application/json',
      'Authorization' => "Bearer #{user_api_jwt}",
      'HTTP_ORIGIN'   => 'example.com'
    }

    params = {
      currency: 'BTC',
      amount: '0.01',
      otp: 'wrong-245924',
      rid: '0xb111'
    }
    VCR.use_cassette('otp-invalid') do
      post '/api/v1/withdrawals', params: params, headers: headers
    end
    expect(response).to have_http_status(:unprocessable_entity)
  end


end
