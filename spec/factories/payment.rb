FactoryBot.define do
  factory :payment do
    amount { booking.trip.full_cost * 10 }
    raw_response { {} }

    booking
  end
end
