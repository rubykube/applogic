# frozen_string_literal: true

require 'rails_helper'

describe APIv1::Auth::JWTAuthenticator do
  let :token do
    'Bearer ' + jwt_build(payload)
  end

  let :endpoint do
    double('endpoint', options: { route_options: { scopes: ['identity'] } })
  end

  let :request do
    double 'request', \
      request_method: 'GET',
      path_info:      '/users/me',
      env:            { 'api.endpoint'  => endpoint },
      headers:        { 'Authorization' => token }
  end

  let :payload do
    { x: 'x', y: 'y', z: 'z', uid: 'O90Y88JDPQ7167' }
  end

  subject { APIv1::Auth::JWTAuthenticator.new(request.headers['Authorization']) }

  it 'should work in standard conditions' do
    expect(subject.authenticate!).to eq payload.slice(:uid)
  end

  it 'should raise exception when uid is not provided' do
    payload.delete(:uid)
    expect { subject.authenticate! }.to raise_error(APIv1::AuthorizationError) { |e| expect(e.reason).to match /key not found: :uid/ }
  end

  it 'should raise exception when uid is blank' do
    payload[:uid] = ''
    expect { subject.authenticate! }.to raise_error(APIv1::AuthorizationError) { |e| expect(e.reason).to match /blank/ }
  end

  it 'should raise exception when token is expired' do
    payload[:exp] = 1.minute.ago.to_i
    expect { subject.authenticate! }.to raise_error(APIv1::AuthorizationError) { |e| expect(e.reason).to match /expired/ }
  end

  it 'should raise exception when token type is invalid' do
    subject.instance_variable_set(:@token_type, 'Foo')
    expect { subject.authenticate! }.to raise_error(APIv1::AuthorizationError) { |e| expect(e.reason).to match /invalid/ }
  end

  describe 'exception-safe authentication' do
    it 'should not raise exceptions' do
      payload.delete(:uid)
      expect { subject.authenticate }.not_to raise_error
    end
  end

  context 'valid issuer' do
    before { ENV['JWT_ISSUER'] = 'qux' }
    before { payload[:iss] = 'qux' }
    after  { ENV.delete('JWT_ISSUER') }
    it('should validate issuer') { expect(subject.authenticate!).to eq payload.slice(:uid) }
  end

  context 'invalid issuer' do
    before { ENV['JWT_ISSUER'] = 'qux' }
    before { payload[:iss] = 'hacker' }
    after  { ENV.delete('JWT_ISSUER') }
    it 'should validate issuer' do
      expect { subject.authenticate! }.to raise_error(APIv1::AuthorizationError) { |e| expect(e.reason).to match /issuer/ }
    end
  end

  context 'valid audience' do
    before { ENV['JWT_AUDIENCE'] = 'foo,bar' }
    before { payload[:aud] = ['bar'] }
    after  { ENV.delete('JWT_AUDIENCE') }
    it('should validate audience') { expect(subject.authenticate!).to eq payload.slice(:uid) }
  end

  context 'invalid audience' do
    before { ENV['JWT_AUDIENCE'] = 'foo,bar' }
    before { payload[:aud] = ['baz'] }
    after  { ENV.delete('JWT_AUDIENCE') }
    it 'should validate audience' do
      expect { subject.authenticate! }.to raise_error(APIv1::AuthorizationError) { |e| expect(e.reason).to match /audience/ }
    end
  end

  context 'missing JWT ID' do
    before { payload[:jti] = nil }
    it 'should require JTI' do
      expect { subject.authenticate! }.to raise_error(APIv1::AuthorizationError) { |e| expect(e.reason).to match /jti/ }
    end
  end

  context 'issued at in future' do
    before { payload[:iat] = 200.seconds.from_now.to_i }
    it 'should not allow JWT' do
      expect { subject.authenticate! }.to raise_error(APIv1::AuthorizationError) { |e| expect(e.reason).to match /iat/ }
    end
  end

  context 'issued at before future' do
    before { payload[:iat] = 3.seconds.ago.to_i }
    it('should allow JWT') { expect(subject.authenticate!).to eq payload.slice(:uid) }
  end
end
