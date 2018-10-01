require 'faker'

FactoryBot.define do
  factory :user do
    address { Faker::Address.full_address }
    email { Faker::Internet.email }
    name { Faker::Name.name }
    password { Faker::Internet.password }
    phone_number { Faker::PhoneNumber.cell_phone }
    type { %w(Guest Guide).sample }
  end
end
