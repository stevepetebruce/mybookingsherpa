require "rails_helper"

RSpec.describe Booking, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:trip) }
    it { is_expected.to belong_to(:guest) }
    it { is_expected.to have_many(:payments) }
  end

  describe "validations" do
    context "email" do
      it { should allow_value(Faker::Internet.email).for(:email) }
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

  it { should define_enum_for(:allergies).with(%i[none other dairy eggs nuts soya]) }
  it { should define_enum_for(:dietary_requirements).with(%i[none other vegan vegetarian]) }
  it { should define_enum_for(:status).with(%i[yellow green]) }

  describe "callbacks" do
    let!(:booking) { FactoryBot.build(:booking) }

    it "should call #enums_none_to_nil" do
      expect(booking).to receive(:enums_none_to_nil)

      booking.save
    end

    it "should call #update_priority after_save" do
      expect(booking).to receive(:update_priority)

      booking.save
    end

    it "should call #update_status after_save" do
      expect(booking).to receive(:update_status)

      booking.save
    end
  end

  describe "#enums_none_to_nil" do
    context "a guest with allergies and dietary_requirements set to 'none'" do
      let(:booking) { FactoryBot.build(:booking, allergies: "none", dietary_requirements: "none") }

      it "should set the fields to nil" do
        expect { booking.send(:enums_none_to_nil) }.to change { booking.allergies }.from('none').to(nil)
      end
    end

    context "a booking with allergies and dietary_requirements values" do
      let!(:allergies) { %i[other dairy eggs nuts soya].sample }
      let!(:dietary_requirements) { %i[other vegan vegetarian].sample }
      let(:booking) { FactoryBot.build(:booking, allergies: allergies, dietary_requirements: dietary_requirements) }

      it "should not change the value of the fields" do
        booking.send(:enums_none_to_nil)

        expect(booking.allergies).to eq(allergies.to_s)
        expect(booking.dietary_requirements).to eq(dietary_requirements.to_s)
      end
    end
  end
end
