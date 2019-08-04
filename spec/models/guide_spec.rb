require 'rails_helper'

RSpec.describe Guide, type: :model do
  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:trips) }
    it { should have_many(:organisations).through(:organisation_memberships) }
  end

  describe 'validations' do
    context 'email' do
      it { should allow_value(Faker::Internet.email).for(:email) }
      it { should allow_value("alan.donohoe@mybookingsherpa.com").for(:email) }
      it { should allow_value("ad591@sussex.ac.uk").for(:email) }
      it { should allow_value("alan+1@example.com").for(:email) }
      it { should_not allow_values(Faker::Lorem.word, Faker::PhoneNumber.cell_phone ).for(:email) }
      it { should validate_presence_of(:email) }
      it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
    end
    context 'name' do
      it { should_not allow_value('<SQL INJECTION>').for(:name) }
      it { should allow_value(Faker::Lorem.word).for(:name) }
    end
    context 'phone_number' do
      it { should allow_value(Faker::PhoneNumber.cell_phone).for(:phone_number) }
      it { should_not allow_value(Faker::Lorem.word).for(:phone_number) }
    end
  end
end
