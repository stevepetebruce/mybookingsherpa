FactoryBot.define do
  factory :allergy do
    name { Allergy::POSSIBLE_ALLERGIES.sample }
  end
end
