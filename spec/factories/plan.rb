FactoryBot.define do
  factory :plan do
    name { Faker::Name.name }

    trait :flat_fee do
      charge_type { :flat_fee }
      flat_fee_amount { Faker::Number.decimal(l_digits: 2) }
    end

    trait :regular do
      name { "regular" }
      charge_type { :percentage }
      percentage_amount { 0.01 }
    end

    trait :discount do
      name { "discount (0.5%)" }
      charge_type { :percentage }
      percentage_amount { 0.005 }
    end
  end
end
