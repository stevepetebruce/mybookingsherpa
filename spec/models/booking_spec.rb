require "rails_helper"

RSpec.describe Booking, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:trip) }
    it { is_expected.to belong_to(:guest).optional(true) }
    it { is_expected.to have_many(:allergies) }
    it { is_expected.to have_many(:dietary_requirements) }
    it { is_expected.to have_many(:payments) }
  end

  describe "validations" do
    context "email" do
      it { should allow_value(Faker::Internet.email).for(:email) }
      it { should allow_value("alan.donohoe@mybookingsherpa.com").for(:email) }
      it { should allow_value("ad591@sussex.ac.uk").for(:email) }
      it { should allow_value("alan+1@example.com").for(:email) }
      it { should_not allow_value(Faker::Lorem.word).for(:email) }
      it { should validate_presence_of(:email) }
    end
    context "country" do
      it { should allow_value(Faker::Address.country_code).for(:country) }
      it { should_not allow_value(Faker::Lorem.word).for(:email) }
    end
    context "name" do
      it { should allow_value(Faker::Name.name).for(:name) }
      it { should_not allow_value("<SQL INJECTION;>").for(:name) }
    end
    context "next_of_kin_name" do
      it { should allow_value(Faker::Name.name).for(:next_of_kin_name) }
      it { should_not allow_value("<SQL INJECTION;>").for(:next_of_kin_name) }
    end
    context "next_of_kin_phone_number" do
      it { should allow_value(Faker::PhoneNumber.cell_phone).for(:next_of_kin_phone_number) }
      it { should_not allow_value( Faker::Name.name).for(:next_of_kin_phone_number) }
    end
    context "phone_number" do
      it { should allow_value(Faker::PhoneNumber.cell_phone).for(:phone_number) }
      it { should_not allow_value( Faker::Name.name).for(:phone_number) }
    end
  end

  it { should define_enum_for(:payment_status).with(%i[payment_required payment_pending full_amount_paid payment_failed refunded]) }

  describe "callbacks" do
    let!(:booking) { FactoryBot.build(:booking) }

    it "should call #update_priority after_save" do
      expect(booking).to receive(:update_priority)

      booking.save
    end
  end
end
