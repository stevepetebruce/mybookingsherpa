FactoryBot.define do
  factory :payment do
    amount { booking.trip.full_cost }
    raw_response { {} }

    booking
  end
end
