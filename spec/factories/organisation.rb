FactoryBot.define do
  factory :organisation do
    address { Faker::Address.full_address }
    currency { %w[eur gbp usd].sample }
    name { Faker::Name.name }
    stripe_account_id { "acct_#{Faker::Bank.account_number(16)}" }
    subdomain { Faker::Internet.domain_word }
  end
end
