class CreateTradeDescriptor < ActiveRecord::Migration[5.2]
  def change
    create_table :trade_descriptors, id: false do |t|
      t.integer :trade_id, null: false
      t.string :uid, null: false, limit: 14
      t.string :state, null: false, default: 'visible', limit: 30
    end
    add_index :trade_descriptors, %i[state uid trade_id]
  end
end
