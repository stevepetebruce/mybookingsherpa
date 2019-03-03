FactoryBot.define do
  factory :guest do
    address { Faker::Address.full_address }
    email { Faker::Internet.email }
    name { Faker::Name.name }
    password { Faker::Internet.password } # TODO: can be blank - need to change
    phone_number { Faker::PhoneNumber.cell_phone }

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
      address_override { Faker::Address.street_address }
      allergies_override { %i[dairy eggs nuts penicillin soya].sample }
      city_override { Faker::Address.city }
      country_override { Faker::Address.country_code }
      county_override { Faker::Address.state }
      date_of_birth_override { Faker::Date.birthday(18, 65) }
      dietary_requirements_override { %i[other vegan vegetarian].sample }
      email_override { Faker::Internet.email }
      medical_conditions_override { Faker::Lorem.sentence }
      name_override { Faker::Name.name }
      next_of_kin_name_override { Faker::Name.name }
      next_of_kin_phone_number_override { Faker::PhoneNumber.cell_phone }
      phone_number_override { Faker::PhoneNumber.cell_phone }
      post_code_override { Faker::Address.postcode }
    end

    trait :all_updatable_fields_empty do
      address { nil }
      name { nil }
      phone_number { nil }
    end

    trait :all_updatable_fields_complete do
      address { Faker::Address.street_address }
      allergies { %i[dairy eggs nuts penicillin soya].sample }
      city { Faker::Address.city }
      country { Faker::Address.country_code }
      county { Faker::Address.state }
      date_of_birth { Faker::Date.birthday(18, 65) }
      dietary_requirements { %i[other vegan vegetarian].sample }
      email { Faker::Internet.email }
      medical_conditions { Faker::Lorem.sentence }
      name { Faker::Name.name }
      next_of_kin_name { Faker::Name.name }
      next_of_kin_phone_number { Faker::PhoneNumber.cell_phone }
      phone_number { Faker::PhoneNumber.cell_phone }
      post_code { Faker::Address.postcode }
    end
  end
end
