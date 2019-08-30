FactoryBot.define do
  factory :booking do
    email { Faker::Internet.email }
    payment_status { :payment_required }
    association :trip, full_cost: 500
    guest

    trait :allergies do
      association :allergy, name: Allergy::POSSIBLE_ALLERGIES.sample
    end

    trait :all_fields_complete do
      country { Faker::Address.country_code }
      date_of_birth { Faker::Date.birthday(18, 65) }
      email { Faker::Internet.email }
      other_information { Faker::Lorem.sentence }
      name { Faker::Name.name }
      next_of_kin_name { Faker::Name.name }
      next_of_kin_phone_number { Faker::PhoneNumber.cell_phone }
      phone_number { Faker::PhoneNumber.cell_phone }
    end

    trait :basic_fields_complete do
      email { Faker::Internet.email }
      name { Faker::Name.name }
    end

    trait :complete_with_allergies do
      country { Faker::Address.country_code }
      date_of_birth { Faker::Date.birthday(18, 65) }
      email { Faker::Internet.email }
      name { Faker::Name.name }
      next_of_kin_name { Faker::Name.name }
      next_of_kin_phone_number { Faker::PhoneNumber.cell_phone }
      phone_number { Faker::PhoneNumber.cell_phone }
      after(:create) do |booking|
        create :allergy, allergic: booking
      end
    end

    trait :complete_with_dietary_requirements do
      country { Faker::Address.country_code }
      date_of_birth { Faker::Date.birthday(18, 65) }
      email { Faker::Internet.email }
      name { Faker::Name.name }
      next_of_kin_name { Faker::Name.name }
      next_of_kin_phone_number { Faker::PhoneNumber.cell_phone }
      phone_number { Faker::PhoneNumber.cell_phone }
      after(:create) do |booking|
        create :dietary_requirement, dietary_requirable: booking
      end
    end

    trait :complete_with_other_information do
      country { Faker::Address.country_code }
      date_of_birth { Faker::Date.birthday(18, 65) }
      email { Faker::Internet.email }
      other_information { Faker::Lorem.sentence }
      name { Faker::Name.name }
      next_of_kin_name { Faker::Name.name }
      next_of_kin_phone_number { Faker::PhoneNumber.cell_phone }
      phone_number { Faker::PhoneNumber.cell_phone }
    end

    trait :complete_without_any_issues do
      country { Faker::Address.country_code }
      date_of_birth { Faker::Date.birthday(18, 65) }
      email { Faker::Internet.email }
      name { Faker::Name.name }
      next_of_kin_name { Faker::Name.name }
      next_of_kin_phone_number { Faker::PhoneNumber.cell_phone }
      phone_number { Faker::PhoneNumber.cell_phone }
    end

    trait :with_payment do
      after(:create) do |booking|
        create :payment, booking: booking
      end
    end
  end
end
