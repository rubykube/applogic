# frozen_string_literal: true

RSpec.describe Barong::System::DocumentVerifiedConsumer do
  describe '.call' do
    let(:event) do
      {
        name: 'system.document.verified',
        email: 'email@example.com'
      }
    end

    subject(:call) { described_class.call(event) }

    before do
      allow(ProfileMailer).to receive_message_chain(:documents_verified, :deliver_now)
    end

    it 'triggers the password reset email mailer' do
      expect(ProfileMailer).to receive(:documents_verified)
        .with('email@example.com')
      call
    end
  end
end
