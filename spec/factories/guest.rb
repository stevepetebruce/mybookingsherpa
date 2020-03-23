FactoryBot.define do
  factory :guest do
    email { Faker::Internet.email }
    password { Faker::Internet.password } # TODO: can be blank - need to change

    trait :allergies do
      after(:create) do |guest|
        create :allergy, allergic: guest
      end
    end

    trait :all_booking_fields_complete do
      country_booking { Faker::Address.country_code }
      date_of_birth_booking { Faker::Date.birthday(min_age: 18, max_age: 65) }
      email_booking { Faker::Internet.email }
      other_information_booking { Faker::Lorem.sentence }
      name_booking { Faker::Name.name }
      next_of_kin_name_booking { Faker::Name.name }
      next_of_kin_phone_number_booking { Faker::PhoneNumber.cell_phone }
      phone_number_booking { Faker::PhoneNumber.cell_phone }
    end

    trait :all_override_fields_complete do
      country { Faker::Address.country_code }
      country_override { country }
      date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
      date_of_birth_override { date_of_birth }
      email { Faker::Internet.email }
      email_override { email }
      other_information { Faker::Lorem.sentence }
      other_information_override { other_information }
      name { Faker::Name.name }
      name_override { name }
      next_of_kin_name { Faker::Name.name }
      next_of_kin_name_override { next_of_kin_name }
      next_of_kin_phone_number { Faker::PhoneNumber.cell_phone }
      next_of_kin_phone_number_override { next_of_kin_phone_number }
      phone_number { Faker::PhoneNumber.cell_phone }
      phone_number_override { phone_number }
    end

    trait :all_updatable_fields_empty do
      name { nil }
      name_override { nil }
      phone_number { nil }
      phone_number_override { nil }
    end

    trait :dietary_requirements do
      after(:create) do |guest|
        create :dietary_requirement, dietary_requirable: guest
      end
    end
  end
end
