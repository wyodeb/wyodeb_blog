# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { 'test@example.com' }
    username { 'testuser' }
    password { 'password' }  # Default password

    trait :without_password do
      after(:build) do |user|
        user.password = nil
        user.password_confirmation = nil
        user.instance_eval do
          def password_required?
            false
          end
        end
      end
    end
  end
end
