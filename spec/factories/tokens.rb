FactoryBot.define do
  factory :token do
    otp { '123456' }
    expires_at { 10.minutes.from_now }

    trait :expired do
      expires_at { 10.minutes.ago }
    end

    trait :invalid_otp do
      otp { 'wrongotp' }
    end
  end
end
