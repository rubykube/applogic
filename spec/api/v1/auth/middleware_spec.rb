# frozen_string_literal: true

require 'rails_helper'

describe APIv1::Auth::Middleware, type: :request do
  class TestApp < Grape::API
    helpers APIv1::Helpers
    use APIv1::Auth::Middleware

    get '/' do
      authenticate!
      current_user.uid
    end
  end

  let(:app) { TestApp.new }

  context 'when using JWT authentication' do
    let(:user) { create(:user, :level_3) }
    let(:payload) { { x: 'x', y: 'y', z: 'z', uid: user.uid } }
    let(:token) { jwt_build(payload) }

    it 'should deny access when token is not given' do
      api_get '/'
      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2001,"message":"Authorization failed"}}'
    end

    it 'should deny access when invalid token is given' do
      api_get '/', token: '123.456.789'
      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2001,"message":"Authorization failed"}}'
    end

    it 'should deny access when member doesn\'t exist' do
      payload[:uid] = 'BARONG1234'
      api_get '/', token: token
      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2001,"message":"Authorization failed"}}'
    end

    it 'should allow access when valid token is given' do
      api_get '/', token: token
      expect(response).to be_successful
      expect(response.body).to eq user.uid
    end
  end

  context 'when not using authentication' do
    it 'should deny access' do
      api_get '/'
      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2001,"message":"Authorization failed"}}'
    end
  end
end
