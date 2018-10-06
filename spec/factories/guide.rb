FactoryBot.define do
  factory :guide do
    address { Faker::Address.full_address }
    email { Faker::Internet.email }
    name { Faker::Name.name }
    password { Faker::Internet.password }
    phone_number { Faker::PhoneNumber.cell_phone }
  end
end
