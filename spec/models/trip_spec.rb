require "rails_helper"

RSpec.describe Trip, type: :model do
  describe "associations" do
    it { should belong_to(:organisation) }
    it { should have_many(:bookings) }
    it { should have_many(:guests).through(:bookings) }
    it { should have_and_belong_to_many(:guides) }
  end

  describe "validations" do
    it { should validate_presence_of(:full_cost) }
    it { should validate_presence_of(:maximum_number_of_guests) }

    describe "name" do
      it { should_not allow_value("<SQL INJECTION>").for(:name) }
      it { should allow_value(Faker::Lorem.word).for(:name) }
      # TODO: check uniqueness to organisation scope
    end

    describe "minimum_number_of_guests" do
      it { should validate_numericality_of(:minimum_number_of_guests).only_integer }
    end

    describe "maximum_number_of_guests" do
      it { should validate_numericality_of(:maximum_number_of_guests).only_integer }
    end

    # TODO: when know format of date string we"re sending back and also test that
    describe "dates" do
      subject { trip.valid? }

      let(:trip) { FactoryBot.build(:trip, start_date: start_date, end_date: end_date) }

      context "valid" do
        context "start_date is before end_date" do
          let(:start_date) { Date.today }
          let(:end_date) { Faker::Date.between(2.days.from_now, 10.days.from_now) }

          it { should be true }
        end
      end

      context "invalid" do
        context "start_date is after end_date" do
          let(:start_date) { Faker::Date.between(2.days.from_now, 10.days.from_now) }
          let(:end_date) { Date.today }

          it { should be false }
        end
      end
    end
  end

  it { should define_enum_for(:currency).with(%i[eur gbp usd]) }

  describe "#currency" do
    subject { described_class.new(attributes).currency }
    let(:organisation) { FactoryBot.create(:organisation, currency: "usd") }

    context "when the trip has not had a currency set" do
      let(:attributes) { { organisation: organisation } }

      it "should be overriden by the organisation's currency" do
        expect(subject).to eq("usd")
      end
    end

    context "when the trip has had a currency set" do
      let(:attributes) { { currency: :gbp, organisation: organisation } }

      it "should be the trip specific currency" do
        expect(subject).to eq("gbp")
      end
    end
  end
end
