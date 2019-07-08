FactoryBot.define do
  factory :trip do
    name { Faker::Name.name }
    full_cost { 500 }
    start_date { Date.today }
    end_date { Date.today + 1.week }
    maximum_number_of_guests { 12 }
    organisation
    guides { |t| [t.association(:guide)] }

    after(:build) do |trip|
      trip.guides.first.organisation_memberships.create(owner: true,
                                                        organisation: trip.organisation)
    end
  end
end
