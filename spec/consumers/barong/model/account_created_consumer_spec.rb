# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Barong::Model::AccountCreatedConsumer do
  let!(:user) { create(:user) }

  describe '.call' do
    let(:event) do
      {
        name: 'model.account.created',
        record: {
          email: 'email@example.com',
          confirmation_token: 'n1Ytj6Hy57YpfueA2vtmnwJQs583bpYn7Wsfr'
        }
      }
    end

    subject(:call) { described_class.call(event) }

    before do
      allow(AccountMailer).to receive_message_chain(:verification_email, :deliver_now)
    end

    it 'triggers the verification email mailer' do
      expect(AccountMailer).to receive(:verification_email)
        .with('email@example.com', 'n1Ytj6Hy57YpfueA2vtmnwJQs583bpYn7Wsfr')
      call
    end
  end
end
