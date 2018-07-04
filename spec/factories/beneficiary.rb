# frozen_string_literal: true

FactoryBot.define do
  factory :beneficiary do
    uid "ID12345"
    full_name { Faker::GameOfThrones.character }
    address { Faker::Address.full_address }
    country { Faker::Address.country }
    account_number { 'GB82 WEST 1234 5698 7654 32' }
    account_type 'iban'
    currency { 'USD' }
    bank_name { Faker::Bank.name }
    bank_address { Faker::Address.full_address }
    bank_country { Faker::Address.country }
  end
end
