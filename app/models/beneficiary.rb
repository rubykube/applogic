# frozen_string_literal: true

class Beneficiary < ApplicationRecord
  STATUSES = %w[approved invalid declined pending].freeze
  ACCOUNT_TYPES = %w[swift iban].freeze

  before_validation :assign_rid

  validates :rid, :uid, :full_name, :address, :country, :account_number,
            :account_type, :bank_name, :bank_address, :bank_country,
            :currency, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :account_type, inclusion: { in: ACCOUNT_TYPES }

  scope :by_current_user, ->(user) { where(uid: user.uid) }
  scope :active, -> { where(status: 'approved') }
  validate :validate_iban, if: proc { |m| m.account_type == 'iban' }
  validate :validate_is_not_iban, if: proc { |m| m.account_type != 'iban' }
  validates :bank_swift_code, presence: true, if: proc { |m| m.account_type == 'swift' }

  private

  def validate_iban
    return if IBANTools::IBAN.valid?(account_number)
    errors.add(:account_number, 'IBAN is invalid')
  end

  def validate_is_not_iban
    return unless IBANTools::IBAN.valid?(account_number)
    errors.add(:account_number, 'IBAN is available only for iban account type')
  end

  def assign_rid
    return unless rid.blank?
    loop do
      self.rid = random_rid
      break unless self.class.where(rid: rid).any?
    end
  end

  def random_rid
    "RID#{SecureRandom.hex(5).upcase}"
  end
end
