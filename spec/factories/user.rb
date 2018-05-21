# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    level 0
    state 'active'
    uid { Faker::Internet.password(14, 14) }
  end
end
