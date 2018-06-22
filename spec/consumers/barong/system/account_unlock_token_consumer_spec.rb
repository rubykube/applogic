# frozen_string_literal: true

RSpec.describe Barong::System::AccountUnlockTokenConsumer do
  describe '.call' do
    let(:event) do
      {
        name: 'system.account.unlock_token',
        email: 'email@example.com',
        token: 'n1Ytj6Hy57YpfueA2vtmnwJQs583bpYn7Wsfr'
      }
    end

    subject(:call) { described_class.call(event) }

    before do
      allow(AccountMailer).to receive_message_chain(:unlock_instructions, :deliver_now)
    end

    it 'triggers the unlock instructions email mailer' do
      expect(AccountMailer).to receive(:unlock_instructions)
        .with('email@example.com', 'n1Ytj6Hy57YpfueA2vtmnwJQs583bpYn7Wsfr')
      call
    end
  end
end
