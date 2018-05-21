# frozen_string_literal: true

require 'rails_helper'

describe User do
  let(:user) { create(:user) }

  it 'ignores new values for email' do
    previous_value = user.email
    user.update!(email: 'new@gmail.com')
    expect(user.reload.email).to eq previous_value
  end

  it 'ignores new values for uid' do
    previous_value = user.uid
    user.update!(uid: '1234567890')
    expect(user.reload.uid).to eq previous_value
  end
end
