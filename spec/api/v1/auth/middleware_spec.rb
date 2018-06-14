# frozen_string_literal: true

require 'rails_helper'

describe APIv1::Auth::Middleware, type: :request do
  class TestApp < Grape::API
    helpers APIv1::Helpers
    use APIv1::Auth::Middleware

    get '/' do
      authenticate!
      current_uid
    end
  end

  let(:app) { TestApp.new }

  context 'when using JWT authentication' do
    let(:payload) { { x: 'x', y: 'y', z: 'z', uid: 'O90Y88JDPQ7167' } }
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

    it 'should allow access when valid token is given' do
      api_get '/', token: token
      expect(response).to be_successful
      expect(response.body).to eq payload[:uid]
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
