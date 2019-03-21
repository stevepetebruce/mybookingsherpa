FactoryBot.define do
  factory :booking do
    email { Faker::Internet.email }
    status { :yellow }
    association :trip, full_cost: 500
    guest

    trait :all_fields_complete do
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

    trait :basic_fields_complete do
      email { Faker::Internet.email }
      name { Faker::Name.name }
    end

    trait :complete_with_allergies do
      address { Faker::Address.street_address }
      allergies { %i[dairy eggs nuts penicillin soya].sample }
      city { Faker::Address.city }
      country { Faker::Address.country_code }
      county { Faker::Address.state }
      date_of_birth { Faker::Date.birthday(18, 65) }
      email { Faker::Internet.email }
      name { Faker::Name.name }
      next_of_kin_name { Faker::Name.name }
      next_of_kin_phone_number { Faker::PhoneNumber.cell_phone }
      phone_number { Faker::PhoneNumber.cell_phone }
      post_code { Faker::Address.postcode }
    end

    trait :complete_with_dietary_requirements do
      address { Faker::Address.street_address }
      city { Faker::Address.city }
      country { Faker::Address.country_code }
      county { Faker::Address.state }
      date_of_birth { Faker::Date.birthday(18, 65) }
      dietary_requirements { %i[other vegan vegetarian].sample }
      email { Faker::Internet.email }
      name { Faker::Name.name }
      next_of_kin_name { Faker::Name.name }
      next_of_kin_phone_number { Faker::PhoneNumber.cell_phone }
      phone_number { Faker::PhoneNumber.cell_phone }
      post_code { Faker::Address.postcode }
    end

    trait :complete_with_medical_conditions do
      address { Faker::Address.street_address }
      city { Faker::Address.city }
      country { Faker::Address.country_code }
      county { Faker::Address.state }
      date_of_birth { Faker::Date.birthday(18, 65) }
      email { Faker::Internet.email }
      medical_conditions { Faker::Lorem.sentence }
      name { Faker::Name.name }
      next_of_kin_name { Faker::Name.name }
      next_of_kin_phone_number { Faker::PhoneNumber.cell_phone }
      phone_number { Faker::PhoneNumber.cell_phone }
      post_code { Faker::Address.postcode }
    end

    trait :complete_without_any_issues do
      address { Faker::Address.street_address }
      city { Faker::Address.city }
      country { Faker::Address.country_code }
      county { Faker::Address.state }
      date_of_birth { Faker::Date.birthday(18, 65) }
      email { Faker::Internet.email }
      name { Faker::Name.name }
      next_of_kin_name { Faker::Name.name }
      next_of_kin_phone_number { Faker::PhoneNumber.cell_phone }
      phone_number { Faker::PhoneNumber.cell_phone }
      post_code { Faker::Address.postcode }
    end
  end
end
