# frozen_string_literal: true

module APIv1
  class Trade < Grape::API
    before { authenticate! }

    desc 'List your trades.'
    get '/trades' do
      response = Faraday.get(ENV.fetch('PEATIO_ROOT_URL') + '/api/v2/trades/my', params, headers.slice('Authorization'))
      if response.status == 200
        excluded_ids = ::TradeDescriptor.where.not(state: :visible).where(uid: env['api.v1.authenticated_uid']).pluck(:trade_id).to_set
        trades = JSON.parse(response.body).reject { |trade| trade['id'].in?(excluded_ids) }
        body trades
        status 200
      else
        status 500
      end
    end
  end
end
