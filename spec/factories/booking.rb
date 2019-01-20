FactoryBot.define do
  factory :booking do
    email { Faker::Internet.email }
    status { :pending }
    trip
  end
end
