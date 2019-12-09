FactoryBot.define do
  factory :trip do
    name { Faker::Name.name }
    full_cost { 500 }
    start_date { Time.zone.today }
    end_date { Time.zone.today + 1.week }
    maximum_number_of_guests { 12 }
    association :organisation
    guides { |t| [t.association(:guide)] }

    trait :with_deposit do
      deposit_percentage { 10 }
    end

    after(:build) do |trip|
      trip.guides.first.organisation_memberships.create(owner: true,
                                                        organisation: trip.organisation)
    end
  end
end
