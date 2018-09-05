require 'rails_helper'

describe User, type: :model do
  context 'associations' do
  end
  context 'validations' do
    context 'email' do
      it { should allow_value(Faker::Internet.email).for(:email) }
      it { should_not allow_values(Faker::Lorem.word, Faker::PhoneNumber.cell_phone ).for(:email) }
      it { should validate_presence_of(:email) }
      it { should validate_uniqueness_of(:email) }
    end
    context 'name' do
      it { should_not allow_value('<SQL INJECTION>').for(:name) }
      it { should allow_value(Faker::Lorem.word).for(:name) }
    end
    context 'phone_number' do
      it { should allow_value(Faker::PhoneNumber.cell_phone).for(:phone_number) }
      it { should_not allow_value(Faker::Lorem.word).for(:email) }
    end
    context 'type' do
      it { should allow_values('Guide', 'Guest').for(:type) }
      it { should_not allow_values(Faker::Lorem.word).for(:type) }
      it { should validate_presence_of(:type) }
    end
  end
end
