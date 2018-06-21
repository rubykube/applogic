# frozen_string_literal: true

describe Peatio::Model::DepositUpdatedConsumer do
  describe '.call' do
    context 'with a deposit updated event' do
      let(:received_event) do
        {
          name: 'model.deposit.updated',
          record: {
            tid:                      'TID9493F6CD41',
            uid:                      'ID092B2AF8E87',
            email:                    'syber.junkie@gmail.com',
            currency:                 'btc',
            amount:                   '0.0855',
            state:                    'accepted',
            created_at:               '2018-04-12T17:16:06+03:00',
            updated_at:               '2018-04-12T18:46:57+03:00',
            completed_at:             '2018-04-12T18:46:57+03:00',
            blockchain_address:       'n1Ytj6Hy57YpfueA2vtmnwJQs583bpYn7W',
            blockchain_txid:          'c37ae1677c4c989dbde9ac22be1f3ff3ac67ed24732a9fa8c9258[..]',
            blockchain_confirmations: 7
          },
          changes: {
            state:                    'submitted',
            completed_at:             nil,
            blockchain_confirmations: 1,
            updated_at:               '2018-04-12T17:16:06+03:00'
          }
        }
      end

      let!(:deposit) do
        record = received_event.dig(:record)

        OpenStruct.new(
          email: record[:email],
          id: record[:tid],
          amount_currency: record[:currency],
          amount: record[:amount],
          created_at: record[:created_at]
        )
      end

      it 'calls the deposit confirmation mailer' do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(DepositMailer)
          .to receive(:confirmation_email)
          .with(deposit)
          .and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_now)
        described_class.call(received_event)
      end
    end
  end
end
