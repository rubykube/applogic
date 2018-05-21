# frozen_string_literal: true

class User < ApplicationRecord
  serialize :options, JSON

  validates_lengths_from_database
  validates :email, email: true, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :level, numericality: { greater_than_or_equal_to: 0 }
  validates :uid, presence: true, uniqueness: { case_sensitive: false }

  attr_readonly :uid, :email

  def email=(value)
    super value.try(:downcase)
  end

  def uid=(value)
    super value.try(:upcase)
  end

  def state
    super.inquiry
  end
end
