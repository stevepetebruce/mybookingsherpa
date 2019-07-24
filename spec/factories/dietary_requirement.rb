FactoryBot.define do
  factory :dietary_requirement do
    name { DietaryRequirement::POSSIBLE_DIETARY_REQUIREMENTS.sample }

    trait :for_booking do
      association :dietary_requirable, factory: :booking
    end

    trait :for_guest do
      association :dietary_requirable, factory: :guest
    end
  end
end
