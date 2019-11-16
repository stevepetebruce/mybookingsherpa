FactoryBot.define do
  factory :payment do
    amount { booking.trip.full_cost }
    raw_response { {} }

    booking

    trait :failed do
      status { :failed }
      raw_response do
        {
          failure_code: 400,
          failure_message: "Request failed"
        }
      end
    end
  end
end
