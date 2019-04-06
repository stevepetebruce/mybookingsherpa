FactoryBot.define do
  factory :organisation do
    address { Faker::Address.full_address }
    currency { %w[eur gbp usd].sample }
    name { Faker::Name.name }
    stripe_account_id { "acct_#{Faker::Bank.account_number(16)}" }
    subdomain do 
      domain_word = Faker::Internet.domain_word
      domain_word.length.between?(3,30) ? domain_word : Faker::Internet.domain_word
    end

    trait :without_stripe_account_id do
      stripe_account_id { nil }
    end
  end
end
