FactoryBot.define do
  factory :onboarding do
    organisation

    trait :onboarding_complete do
      complete { true }
      bank_account_complete { true }
      stripe_account_complete { true }
    end
  end
end
