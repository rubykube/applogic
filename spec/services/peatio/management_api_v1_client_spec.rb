# frozen_string_literal: true

require 'rails_helper'

describe Peatio::ManagementAPIv1Client do
  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  before do
    if respond_to?(:request_body) && respond_to?(:response_body)
      stub_request(:post, 'http://127.0.0.1:18332/').with(body: request_body).to_return(body: response_body)
    end
  end

  let(:withdraw_params) do

  end
end


# describe Peatio::Deposit::CreateService do
#   describe '.call' do
#     let(:user) { create(:user) }
#
#     let!(:deposit) do
#       create(:deposit,
#              bitpesa_transaction_id: 'b1f076dd-d003-42b0-836a-8c571a129f60',
#              uid: user.uid,
#              exists_on_peatio: false,
#              confirmed_amount_cents: build(:deposit).amount_cents)
#     end
#
#     let!(:transaction_state) do
#       TransactionState.create!(
#         state: 'new',
#         bitpesa_transaction_id: deposit.bitpesa_transaction_id
#       )
#     end
#
#     let(:input_params) do
#       {
#         bitpesa_transaction_id: deposit.bitpesa_transaction_id
#       }
#     end
#
#     let(:output_params) do
#       {
#         uid: user.uid,
#         tid: deposit.bitpesa_transaction_id,
#         currency: deposit.amount_currency,
#         amount: deposit.amount_money.to_s,
#         state: 'submitted'
#       }
#     end
#
#     subject(:call) { described_class.call(input_params) }
#
#     before do
#       allow(RequestService).to receive(:call).and_return(true)
#     end
#
#     it 'calls RequestService with correct params' do
#       expect(RequestService).to receive(:call).with(
#         path: '/management_api/v1/deposits/new',
#         method: :post,
#         params: output_params,
#         app: 'peatio'
#       )
#
#       call
#     end
#
#     it 'calls mark_sent_to_peatio! on the transaction' do
#       expect_any_instance_of(Deposit).to receive(:mark_sent_to_peatio!)
#       call
#     end
#   end
# end
