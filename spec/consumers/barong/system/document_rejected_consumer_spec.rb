# frozen_string_literal: true

RSpec.describe Barong::System::DocumentRejectedConsumer do
  describe '.call' do
    let(:event) do
      {
        name: 'system.document.rejected',
        email: 'email@example.com'
      }
    end

    subject(:call) { described_class.call(event) }

    before do
      allow(ProfileMailer).to receive_message_chain(:documents_rejected, :deliver_now)
    end

    it 'triggers the password reset email mailer' do
      expect(ProfileMailer).to receive(:documents_rejected)
        .with('email@example.com')
      call
    end
  end
end
