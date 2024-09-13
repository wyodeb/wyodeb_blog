# spec/factories/posts.rb
FactoryBot.define do
  factory :post do
    association :user
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    status { :draft }

    after(:build) do |post|
      post.slug = post.title.parameterize
    end

    trait :with_categories do
      after(:create) do |post|
        categories = create_list(:category, 2) # Creates 2 categories by default
        post.categories << categories
      end
    end
  end
end
