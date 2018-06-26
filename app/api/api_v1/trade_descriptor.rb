# frozen_string_literal: true

module APIv1
  class TradeDescriptor < Grape::API
    before { authenticate! }

    desc 'Toggle trade visibility.'
    put '/trade_descriptors/:trade_id/toggle' do
      filters = { uid: env['api.v1.authenticated_uid'], trade_id: params[:trade_id] }
      record  = ::TradeDescriptor.find_or_initialize_by(uid: env['api.v1.authenticated_uid'], trade_id: params[:trade_id])
      updates = { state: record.state == 'visible' ? 'invisible' : 'visible' }

      if record.new_record?
        record.save!
      else
        record.class.where(filters).update_all(updates)
      end

      body updates.slice(:state).merge(trade_id: record.trade_id)
      status 200
    end
  end
end
