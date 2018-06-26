# frozen_string_literal: true

require 'rails_helper'

describe APIv1::TradeDescriptor, type: :request do
  let(:user) { create(:user, :level_3) }
  let(:token) { jwt_for(user) }

  it 'creates trade descriptor with state "invisible"' do
    api_put '/api/v1/trade_descriptors/351/toggle', token: token
    expect(response).to have_http_status 200
    expect(response.body).to eq '{"state":"invisible","trade_id":351}'
  end
end
