# frozen_string_literal: true

# spec/factories/categories.rb
FactoryBot.define do
  factory :category do
    name { Faker::Lorem.word }
  end
end
