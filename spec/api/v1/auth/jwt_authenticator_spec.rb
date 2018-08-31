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

  let :user do
    create(:user, :level_3)
  end

  let :payload do
    { x: 'x', y: 'y', z: 'z', uid: user.uid }
  end

  subject { APIv1::Auth::JWTAuthenticator.new(request.headers['Authorization']) }

  it 'should work in standard conditions' do
    expect(subject.authenticate!).to eq user.uid
  end

  it 'should raise exception when uid is not provided' do
    payload.delete(:uid)
    expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /key not found: :uid/ }
  end

  it 'should raise exception when uid is blank' do
    payload[:uid] = ''
    expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /blank/ }
  end

  it 'should raise exception when token is expired' do
    payload[:exp] = 1.minute.ago.to_i
    expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /failed to decode and verify jwt/i }
  end

  describe 'exception-safe authentication' do
    it 'should not raise exceptions' do
      payload.delete(:uid)
      expect { subject.authenticate }.not_to raise_error
    end
  end

  describe 'authentication options' do
    it 'should return uid if return: :uid specified' do
      expect(subject.authenticate!(return: :uid)).to eq payload[:uid]
    end

    it 'should return user if return: :user specified' do
      create(:user)
      payload[:uid] = user.uid
      expect(subject.authenticate!(return: :user)).to eq user
    end
  end

  describe 'on the fly registration' do
    context 'token not issued by Barong' do
      before { payload[:iss] = 'someone' }
      it 'should not register user unless token is issued by Barong' do
        expect { subject.authenticate! }.not_to change(User, :count)
      end
    end

    context 'token issued by Barong' do
      before { payload[:iss] = 'barong' }

      it 'should require level to be present in payload' do
        payload.merge!(state: 'pending', uid: Faker::Internet.password(14, 14), email: Faker::Internet.email)
        expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /key not found: :level/ }
      end

      it 'should require state to be present in payload' do
        payload.merge!(level: 1, uid: Faker::Internet.password(14, 14), email: Faker::Internet.email)
        expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /key not found: :state/ }
      end

      it 'should require UID to be present in payload' do
        payload.merge!(level: 1, state: 'disabled', email: Faker::Internet.email).delete(:uid)
        expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /key not found: :uid/ }
      end

      it 'should require UID to be not blank' do
        payload.merge!(level: 1, state: 'disabled', email: Faker::Internet.email, uid: ' ')
        expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /UID is blank/ }
      end

      it 'should raise exception when email is invalid' do
        payload[:email] = '@gmail.com'
        expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /invalid/ }
      end

      it 'should register user' do
        payload.merge!(email: 'guyfrombarong@email.com', uid: 'BARONG1234', state: 'active', level: 2)
        expect { subject.authenticate! }.to change(User, :count).by(1)
        record = User.last
        expect(record.uid).to eq payload[:uid]
        expect(record.level).to eq 2
      end

      it 'should update user if exists' do
        user = create(:user, :level_1)
        payload.merge!(email: Faker::Internet.email, uid: user.uid, state: 'blocked', level: 3)
        expect { subject.authenticate! }.not_to change(User, :count)
        user.reload
        expect(user.uid).to eq payload[:uid]
        expect(user.level).to eq 3
      end

      it 'should register new user and return instance' do
        payload.merge!(email: 'guyfrombarong@email.com', uid: 'BARONG1234', state: '', level: 100)
        expect(subject.authenticate!(return: :user)).to eq User.last
        expect(User.last.level).to eq 100
      end
    end
  end
end
