# frozen_string_literal: true

class CreateBeneficiaries < ActiveRecord::Migration[5.2]
  # rubocop:disable Metrics/AbcSize
  def change
    create_table :beneficiaries do |t|
      t.string :rid, limit: 13, null: false, index: { unique: true }
      t.string :uid, limit: 12, null: false, index: true
      t.string :full_name, null: false
      t.string :address, null: false
      t.string :country, null: false
      t.string :currency, null: false
      t.string :account_number, null: false
      t.string :account_type, null: false
      t.string :bank_name, null: false
      t.string :bank_address, null: false
      t.string :bank_country, null: false
      t.string :bank_swift_code, null: true
      t.string :intermediary_bank_name, null: true
      t.string :intermediary_bank_address, null: true
      t.string :intermediary_bank_country, null: true
      t.string :intermediary_bank_swift_code, null: true
      t.string :status, null: false, default: 'approved'

      t.timestamps null: false
    end
  end
  # rubocop:enable Metrics/AbcSize
end
