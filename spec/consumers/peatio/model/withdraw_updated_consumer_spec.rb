# frozen_string_literal: true

RSpec.describe Peatio::Model::WithdrawUpdatedConsumer do
  let(:user) { create(:user, uid: 'ID092B2AF8E87') }

  describe '.call' do
    context 'with a withdrawal updated event' do
      let(:received_event) do
        {
          name: 'model.withdraw.updated',
          record: {
            tid:             'TID892F29F094',
            uid:             'ID092B2AF8E87',
            email:           'syber.junkie@gmail.com',
            rid:             '0xdA35deE8EDDeAA556e4c26268463e26FB91ff74f',
            currency:        'btc',
            amount:          '4.5485',
            fee:             '0.0015',
            state:           'succeed',
            created_at:      '2018-04-12T18:52:16+03:00',
            updated_at:      '2018-04-12T18:56:23+03:00',
            completed_at:    '2018-04-12T18:56:23+03:00',
            blockchain_txid: '0x9c34d1750e225a95938f9884e857ab6f55eedda43b159d13abf773fe6a916164'
          },
          changes: {
            state:           'processing',
            updated_at:      '2018-04-12T18:55:39+03:00',
            completed_at:    '2018-04-12T18:55:39+03:00',
            blockchain_txid: nil
          }
        }
      end

      let!(:withdrawal) do
        record = received_event.dig(:record)

        OpenStruct.new(
          email: record[:email],
          id: record[:tid],
          address: record[:rid],
          amount_currency: record[:currency],
          amount: record[:amount],
          fee: record[:fee],
          created_at: record[:created_at]
        )
      end

      it 'calls the deposit confirmation mailer' do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(WithdrawalMailer)
          .to receive(:confirmation_email)
          .with(withdrawal)
          .and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_now)
        described_class.call(received_event)
      end
    end
  end
end
