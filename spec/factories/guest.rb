FactoryBot.define do
  factory :guest do
    email { Faker::Internet.email }
    password { Faker::Internet.password } # TODO: can be blank - need to change

    trait :all_booking_fields_complete do
      allergies_booking { %i[dairy eggs nuts penicillin soya].sample }
      country_booking { Faker::Address.country_code }
      date_of_birth_booking { Faker::Date.birthday(18, 65) }
      dietary_requirements_booking { %i[other vegan vegetarian].sample }
      email_booking { Faker::Internet.email }
      other_information_booking { Faker::Lorem.sentence }
      name_booking { Faker::Name.name }
      next_of_kin_name_booking { Faker::Name.name }
      next_of_kin_phone_number_booking { Faker::PhoneNumber.cell_phone }
      phone_number_booking { Faker::PhoneNumber.cell_phone }
    end

    trait :all_override_fields_complete do
      allergies { %i[dairy eggs nuts penicillin soya].sample }
      allergies_override { allergies }
      country { Faker::Address.country_code }
      country_override { country }
      date_of_birth { Faker::Date.birthday(18, 65) }
      date_of_birth_override { date_of_birth }
      dietary_requirements { %i[other vegan vegetarian].sample }
      dietary_requirements_override {dietary_requirements }
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
  end
end
