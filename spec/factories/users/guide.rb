FactoryBot.define do
  factory :guide, parent: :user, class: 'Guide' do
    address { Faker::Address.full_address }
    email { Faker::Internet.email }
    name { Faker::Name.name }
    phone_number { Faker::PhoneNumber.cell_phone }
    type { 'Guide' }
  end
end
