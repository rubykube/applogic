# frozen_string_literal: true

module APIv1
  module Entities
    class Beneficiary < Grape::Entity
      format_with(:iso_timestamp) { |d| d.utc.iso8601 }

      expose :rid, documentation: { type: 'String' }
      expose :uid, documentation: { type: 'String' }
      expose :full_name, documentation: { type: 'String' }
      expose :address, documentation: { type: 'String' }
      expose :country, documentation: { type: 'String' }
      expose :currency, documentation: { type: 'String' }
      expose :account_number, documentation: { type: 'String' }
      expose :account_type, documentation: { type: 'String' }
      expose :bank_name, documentation: { type: 'String' }
      expose :bank_address, documentation: { type: 'String' }
      expose :bank_country, documentation: { type: 'String' }
      expose :bank_swift_code, documentation: { type: 'String' }
      expose :intermediary_bank_name, documentation: { type: 'String' }
      expose :intermediary_bank_address, documentation: { type: 'String' }
      expose :intermediary_bank_country, documentation: { type: 'String' }
      expose :intermediary_bank_swift_code, documentation: { type: 'String' }
      expose :status, documentation: { type: 'String' }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end
