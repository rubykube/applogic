# frozen_string_literal: true

RSpec.describe Barong::System::AccountResetPasswordTokenConsumer do
  describe '.call' do
    let(:event) do
      {
        name: 'system.account.reset_password_token',
        email: 'email@example.com',
        token: 'n1Ytj6Hy57YpfueA2vtmnwJQs583bpYn7Wsfr'
      }
    end

    subject(:call) { described_class.call(event) }

    before do
      allow(AccountMailer).to receive_message_chain(:password_reset_email, :deliver_now)
    end

    it 'triggers the password reset email mailer' do
      expect(AccountMailer).to receive(:password_reset_email)
        .with('email@example.com', 'n1Ytj6Hy57YpfueA2vtmnwJQs583bpYn7Wsfr')
      call
    end
  end
end
