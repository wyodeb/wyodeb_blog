FactoryBot.define do
  factory :comment do
    content { "This is a test comment" }
    association :post
    association :user
  end
end
