# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    level 0
    state 'active'
    uid { "ID#{SecureRandom.hex(5).upcase}" }
  end

  trait :level_3 do
    level 3
  end

  trait :level_2 do
    level 2
  end

  trait :level_1 do
    level 1
  end

  trait :level_5 do
    level 5
  end
end
