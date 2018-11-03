FactoryBot.define do
  factory :trip do
    name { Faker::Name.name }
    organisation
  end
end
