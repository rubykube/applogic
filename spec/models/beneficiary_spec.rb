# frozen_string_literal: true

require 'rails_helper'

describe User do
  describe 'check iban' do
    context 'when account_type is iban' do
      let!(:beneficiary) { build(:beneficiary, account_type: 'iban') }

      it 'valid if number is iban' do
        beneficiary.account_number = 'GB82 WEST 1234 5698 7654 32'
        expect(beneficiary).to be_valid
      end

      it 'invalid if type is not iban' do
        beneficiary.account_number = Faker::Bank.swift_bic
        beneficiary.valid?
        expect(beneficiary.errors.messages).to eq(account_number: ['IBAN is invalid'])
      end
    end

    context 'when account_type is swift' do
      let!(:beneficiary) do
        build(:beneficiary, account_type: 'swift')
      end

      it 'valid if number is not iban and bank_swift_code is present' do
        beneficiary.account_number = Faker::Bank.swift_bic
        beneficiary.bank_swift_code = Faker::Bank.swift_bic
        expect(beneficiary).to be_valid
      end

      it 'invalid if number is iban and bank_swift_code is present' do
        beneficiary.account_number = 'GB82 WEST 1234 5698 7654 32'
        beneficiary.bank_swift_code = Faker::Bank.swift_bic
        beneficiary.valid?
        expect(beneficiary.errors.messages).to eq(account_number: ['IBAN is available only for iban account type'])
      end

      it 'invalid if number is swift but bank_swift_code is missing' do
        beneficiary.account_number = Faker::Bank.swift_bic
        beneficiary.bank_swift_code = nil
        beneficiary.valid?
        expect(beneficiary.errors.messages).to eq(bank_swift_code: ["can't be blank"])
      end
    end
  end
end
