FactoryBot.define do
  factory :trip do
    name { Faker::Name.name }
    full_cost { 500 }
    organisation
  end
end
