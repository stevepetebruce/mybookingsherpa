require "rails_helper"

RSpec.describe Guest, type: :model do
  describe "associations" do
    it { should have_many(:bookings) }
    it { should have_many(:trips).through(:bookings) }
  end

  describe "callbacks" do
    let(:guest) { FactoryBot.create(:guest) }

    it "should call #set_updatable_fields after_update" do
      expect(guest).to receive(:set_updatable_fields)

      guest.update(email: Faker::Internet.email)
    end
  end

  describe "validations" do
    context "email" do
      it { should allow_value(Faker::Internet.email).for(:email) }
      it { should_not allow_values(Faker::Lorem.word, Faker::PhoneNumber.cell_phone ).for(:email) }
      it { should validate_presence_of(:email) }
      it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
    end
    context "name" do
      it { should_not allow_value("<SQL INJECTION>").for(:name) }
      it { should allow_value(Faker::Lorem.word).for(:name) }
    end
    context "phone_number" do
      it { should allow_value(Faker::PhoneNumber.cell_phone).for(:phone_number) }
      it { should_not allow_value(Faker::Lorem.word).for(:phone_number) }
    end
  end

  it { should define_enum_for(:allergies).with(%i[dairy eggs nuts penicillin soya]) }
  it { should define_enum_for(:dietary_requirements).with(%i[other vegan vegetarian]) }
end
