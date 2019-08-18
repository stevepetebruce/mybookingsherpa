FactoryBot.define do
  factory :plan do
    name { Faker::Name.name }

    trait :flat_fee do
      charge_type { :flat_fee }
      flat_fee_amount { Faker::Number.decimal(2) }
    end
  end
end
