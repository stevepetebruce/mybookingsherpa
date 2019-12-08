FactoryBot.define do
  factory :subscription do
    organisation
    # association :plan, :flat_fee

    trait :regular_plan do
      association :plan, :regular
    end
  end
end
