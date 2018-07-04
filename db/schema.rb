# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_06_25_155403) do

  create_table "beneficiaries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "rid", limit: 13, null: false
    t.string "uid", limit: 12, null: false
    t.string "full_name", null: false
    t.string "address", null: false
    t.string "country", null: false
    t.string "currency", null: false
    t.string "account_number", null: false
    t.string "account_type", null: false
    t.string "bank_name", null: false
    t.string "bank_address", null: false
    t.string "bank_country", null: false
    t.string "bank_swift_code"
    t.string "intermediary_bank_name"
    t.string "intermediary_bank_address"
    t.string "intermediary_bank_country"
    t.string "intermediary_bank_swift_code"
    t.string "status", default: "approved", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rid"], name: "index_beneficiaries_on_rid", unique: true
    t.index ["uid"], name: "index_beneficiaries_on_uid"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", null: false
    t.string "uid", limit: 14, null: false
    t.integer "level", limit: 1, default: 0, null: false
    t.string "state", limit: 30, default: "pending", null: false
    t.string "options", limit: 1000, default: "{}", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["state"], name: "index_users_on_state"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

end
