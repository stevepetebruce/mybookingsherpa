FactoryBot.define do
  factory :plan do
    name { Faker::Name.name }
    charge_type { :flat_fee } 
  end
end
