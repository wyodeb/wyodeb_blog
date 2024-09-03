FactoryBot.define do
  factory :post do
    association :user
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    status { :draft }

    after(:build) do |post|
      post.slug = post.title.parameterize
    end
  end
end
