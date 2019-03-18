FactoryBot.define do
  factory :guest do
    email { Faker::Internet.email }
    password { Faker::Internet.password } # TODO: can be blank - need to change

    trait :all_booking_fields_complete do
      address_booking { Faker::Address.street_address }
      allergies_booking { %i[dairy eggs nuts penicillin soya].sample }
      city_booking { Faker::Address.city }
      country_booking { Faker::Address.country_code }
      county_booking { Faker::Address.state }
      date_of_birth_booking { Faker::Date.birthday(18, 65) }
      dietary_requirements_booking { %i[other vegan vegetarian].sample }
      email_booking { Faker::Internet.email }
      medical_conditions_booking { Faker::Lorem.sentence }
      name_booking { Faker::Name.name }
      next_of_kin_name_booking { Faker::Name.name }
      next_of_kin_phone_number_booking { Faker::PhoneNumber.cell_phone }
      phone_number_booking { Faker::PhoneNumber.cell_phone }
      post_code_booking { Faker::Address.postcode }
    end

    trait :all_override_fields_complete do
      address { Faker::Address.street_address }
      address_override { address }
      city { Faker::Address.city }
      city_override { city }
      country { Faker::Address.country_code }
      country_override { country }
      county { Faker::Address.state }
      county_override { county }
      date_of_birth { Faker::Date.birthday(18, 65) }
      date_of_birth_override { date_of_birth }
      email { Faker::Internet.email }
      email_override { email }
      medical_conditions { Faker::Lorem.sentence }
      medical_conditions_override { medical_conditions }
      name { Faker::Name.name }
      name_override { name }
      next_of_kin_name { Faker::Name.name }
      next_of_kin_name_override { next_of_kin_name }
      next_of_kin_phone_number { Faker::PhoneNumber.cell_phone }
      next_of_kin_phone_number_override { next_of_kin_phone_number }
      phone_number { Faker::PhoneNumber.cell_phone }
      phone_number_override { phone_number }
      post_code { Faker::Address.postcode }
      post_code_override { post_code }
    end

    trait :all_updatable_fields_empty do
      address { nil }
      address_override { nil }
      name { nil }
      name_override { nil }
      phone_number { nil }
      phone_number_override { nil }
    end
  end
end
