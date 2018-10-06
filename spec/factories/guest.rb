FactoryBot.define do
  factory :guest do
    address { Faker::Address.full_address }
    email { Faker::Internet.email }
    name { Faker::Name.name }
    password { Faker::Internet.password } # TODO: can be blank - need to change
    phone_number { Faker::PhoneNumber.cell_phone }
  end
end
