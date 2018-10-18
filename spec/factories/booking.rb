FactoryBot.define do
  factory :booking do
    status { :pending }
    trip
  end
end