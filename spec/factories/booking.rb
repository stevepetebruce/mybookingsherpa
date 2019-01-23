FactoryBot.define do
  factory :booking do
    email { Faker::Internet.email }
    status { :pending }
    association :trip, full_cost: 500
  end
end
