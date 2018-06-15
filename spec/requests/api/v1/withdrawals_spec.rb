# frozen_string_literal: true

describe 'POST api/v1/withdrawals' do
  it 'works' do
    user_api_jwt = jwt_build(uid: 'ID1F467E2B9E', aud: %w[applogic barong peatio])

    headers = {
      'Accept'        => 'application/json',
      'Authorization' => "Bearer #{user_api_jwt}",
      'HTTP_ORIGIN'   => 'example.com'
    }

    params = {
      currency: 'BTC',
      amount: '0.01',
      otp: '111-111-111',
      rid: '0xb111'
    }

    post '/api/v1/withdrawals', params: params, headers: headers
    expect(response).to have_http_status(:created)
  end
end
