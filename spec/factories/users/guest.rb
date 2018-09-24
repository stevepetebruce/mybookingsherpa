FactoryBot.define do
  factory :guest, parent: :user, class: 'Guest' do
    address { Faker::Address.full_address }
    email { Faker::Internet.email }
    name { Faker::Name.name }
    phone_number { Faker::PhoneNumber.cell_phone }
    type { 'Guest' }
  end
end
