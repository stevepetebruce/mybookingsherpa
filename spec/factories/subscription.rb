FactoryBot.define do
  factory :subscription do
    organisation
    association :plan, :flat_fee
  end
end
