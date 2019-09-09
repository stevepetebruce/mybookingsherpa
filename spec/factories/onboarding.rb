FactoryBot.define do
  factory :onboarding do
    organisation

    trait :onboarding_complete do
      complete { true }
    end
  end
end
