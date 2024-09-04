

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    username { 'testuser' }
    password { 'password' }

    trait :poster do
      role { :poster }
    end

    trait :commenter do
      role { :commenter }
    end

    trait :without_password do
      password { nil }
      password_confirmation { nil }
      after(:build) do |user|
        user.instance_eval do
          def password_required?
            false
          end
        end
      end
    end
  end
end
