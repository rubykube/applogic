class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.column :email,    :string,  limit: 255,  null: false, index: { unique: true }
      t.column :uid,      :string,  limit: 14,   null: false, index: { unique: true }
      t.column :level,    :integer, limit: 1,    null: false, default: 0
      t.column :state,    :string,  limit: 30,   null: false, default: 'pending', index: true
      t.column :options,  :string,  limit: 1000, null: false, default: '{}'
      t.timestamps null: false
    end
  end
end
