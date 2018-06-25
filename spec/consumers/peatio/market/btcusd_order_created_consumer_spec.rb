# frozen_string_literal: true

describe Peatio::Market::BtcusdOrderCreatedConsumer do
  describe '.call' do
    context 'with btcusd order created event' do
      let(:received_event) do
        {
          name:                   'market.btcusd.order_created',
          market:                 'btcusd',
          type:                   'buy',
          trader_uid:             'ID1F467E2B9E',
          income_unit:            'btc',
          income_fee_type:        'relative',
          income_fee_value:       '0.0015',
          outcome_unit:           'usd',
          outcome_fee_type:       'relative',
          outcome_fee_value:      '0.0',
          initial_income_amount:  '14.0',
          current_income_amount:  '14.0',
          initial_outcome_amount: '0.42',
          current_outcome_amount: '0.42',
          strategy:               'limit',
          price:                  '0.03',
          state:                  'open',
          trades_count:           0,
          created_at:             '2018-05-07T02:12:28Z'
        }
      end

      it 'calls the order created mailer' do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(OrderMailer)
          .to receive(:order_created)
          .with('syber-junkie@example.com', received_event)
          .and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_now)

        pending 'Should be stubbed without VCR'
        VCR.use_cassette('btc-usd-order-created') do
          described_class.call(received_event)
        end
      end
    end
  end
end
