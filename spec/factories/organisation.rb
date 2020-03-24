FactoryBot.define do
  factory :organisation do
    address { Faker::Address.full_address }
    name { Faker::Name.name }
    stripe_account_id_live { "acct_#{Faker::Bank.account_number(digits: 16)}" }
    stripe_account_id_test { "acct_#{Faker::Bank.account_number(digits: 16)}" }

    subdomain do 
      domain_word = Faker::Internet.domain_word
      domain_word.length.between?(3,30) ? domain_word : Faker::Internet.domain_word
    end

    trait :not_on_trial do
      association :onboarding, :onboarding_complete
    end

    trait :on_regular_plan do
      after(:create) do |organisation|
        create :subscription, :regular_plan, organisation: organisation
      end
    end

    trait :with_country_specific_data do
      country_code { %w[fr gb us].sample }
      currency { %w[eur gbp usd].sample }
    end
  end
end
