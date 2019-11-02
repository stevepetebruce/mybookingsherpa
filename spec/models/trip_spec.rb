require "rails_helper"

RSpec.describe Trip, type: :model do
  describe "associations" do
    it { should belong_to(:organisation) }
    it { should have_many(:bookings) }
    it { should have_many(:guests).through(:bookings) }
    it { should have_and_belong_to_many(:guides) }
  end

  describe "callbacks" do
    describe "#set_slug" do
      let!(:trip) { FactoryBot.build(:trip) }

      it "should call #set_slug" do
        expect(trip).to receive(:set_slug)

        trip.save
      end

      it "should have a slug based on the trip name" do
        trip.save

        expect(trip.slug).to eq trip.name.parameterize(separator: "_")
      end

      context "trip with name with odd characters in" do
        before { trip.update(name: "my new trip !!! <>,.!!!") }

        it "should be able to handle/make URL-friendly slugs" do
          expect(trip.slug).to eq "my_new_trip"
        end
      end

      context "a trip with the same name already exists" do
        let!(:trip_with_same_name) { FactoryBot.create(:trip, name: trip.name) }

        it "should not create the same slug" do
          trip.save

          expect(trip_with_same_name.slug).to_not eq(trip.slug)
        end
      end
    end

    describe "#set_deposit_cost" do
      let!(:full_cost) { rand(500...1_000) }
      let!(:trip) { FactoryBot.build(:trip, deposit_percentage: deposit_percentage, full_cost: full_cost) }

      context "deposit_percentage is not nil" do
        let!(:deposit_percentage) { rand(10...50) }

        it "should call #set_deposit_cost" do
          expect(trip).to receive(:set_deposit_cost)

          trip.save
        end

        it "should set the correct deposit cost based on the trip's full_cost and deposit_percentage" do
          trip.save

          expect(trip.deposit_cost).to eq((trip.full_cost * (deposit_percentage.to_f / 100)).to_i)
        end
      end

      context "deposit_percentage is nil" do
        let!(:deposit_percentage) { nil }

        it "should leave deposit_cost as nil" do
          trip.save

          expect(trip.deposit_cost).to be_nil
        end
      end
    end
  end

  describe "validations" do
    it { should validate_presence_of(:full_cost) }
    it { should validate_presence_of(:maximum_number_of_guests) }

    describe "deposit_percentage" do
      it { should validate_numericality_of(:deposit_percentage).only_integer }
    end

    describe "full_payment_window_weeks" do
      it { should validate_numericality_of(:full_payment_window_weeks).only_integer }
    end

    describe "name" do
      it { should allow_value("<SQL INJECTION>").for(:name) } # Rails handles this...
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

    describe "#guest_count" do
      subject(:guest_count) { trip.guest_count }
      # TODO: need to look into this...
      # A booking, in the future may have more than one guest.
      # But guests.count (has_many :guests, through: :bookings)
      # could be a circular reference.

      context "a trip without any bookings" do
        let!(:trip) { FactoryBot.build(:trip) }

        it { expect(guest_count).to eq 0 }
      end

      context "a trip with bookings" do
        let!(:trip) { FactoryBot.create(:trip) }
        let!(:booking) { FactoryBot.create(:booking, trip: trip) }

        it { expect(guest_count).to eq 1 }
      end
    end
  end

  it { should define_enum_for(:currency).with(%i[eur gbp usd]) }

  describe "#currency" do
    subject { described_class.new(attributes).currency }

    context "when the trip has had a currency set" do
      let(:attributes) { { currency: :gbp } }

      it "should be the trip specific currency" do
        expect(subject).to eq("gbp")
      end
    end

    context "when the trip has not had a currency set - but it's organisation has" do
      let(:attributes) { { organisation: organisation } }
      let(:organisation) { FactoryBot.create(:organisation, currency: "usd") }

      it "should be overriden by the organisation's currency" do
        expect(subject).to eq("usd")
      end
    end

    context "when the trip nor it's organisation has had it's currency set" do
      let(:attributes) { { currency: nil } }

      it "should be the default currency" do
        expect(subject).to eq(Trip::DEFAULT_CURRENCY)
      end
    end
  end

  describe "#full_cost" do
    subject(:full_cost) { trip.full_cost }

    let!(:full_cost_in_full_currency) { Faker::Number.between(500, 1_000) }
    let(:trip) { FactoryBot.build(:trip, full_cost: full_cost_in_full_currency) }

    it "should convert the amount in full currency units to cents/pennies" do
      expect(full_cost).to eq (full_cost_in_full_currency * 100)
    end
  end

  describe "#full_payment_date" do
    subject(:full_payment_date) { trip.full_payment_date }

    context "trip with a full_payment_window_weeks value" do
      let(:trip) { FactoryBot.create(:trip, full_payment_window_weeks: rand(2...6)) }

      it "should be the trip_start_date - trip_full_payment_window_weeks" do
        expect(full_payment_date).to eq((trip.start_date - trip.full_payment_window_weeks.weeks))
      end
    end

    context "trip without a full_payment_window_weeks value" do
      let(:trip) { FactoryBot.create(:trip, full_payment_window_weeks: nil) }

      it "should be the trip_start_date - trip_full_payment_window_weeks" do
        expect(full_payment_date).to eq nil
      end
    end
  end

  describe "#has_minimum_number_of_guests?" do
    subject(:has_minimum_number_of_guests?) { trip.has_minimum_number_of_guests? }

    let(:trip) { FactoryBot.build(:trip, minimum_number_of_guests: minimum_number_of_guests) }

    context "trip has the minimum_number_of_guests" do
      let!(:minimum_number_of_guests) { Faker::Number.between(1, 10) }
      let(:number_of_guests_on_trip) { minimum_number_of_guests + Faker::Number.between(0, 5) }

      before do
        allow_any_instance_of(Trip).
          to receive(:guest_count).
          and_return(number_of_guests_on_trip)
      end

      it "should be true" do
        expect(has_minimum_number_of_guests?).to be_truthy
      end
    end

    context "trip does not have the minimum_number_of_guests" do
      let!(:minimum_number_of_guests) { Faker::Number.between(10, 15) }
      let(:number_of_guests_on_trip) { minimum_number_of_guests - Faker::Number.between(1, 5) }

      before do
        allow_any_instance_of(Trip).
          to receive(:guest_count).
          and_return(number_of_guests_on_trip)
      end

      it "should be false" do
        expect(has_minimum_number_of_guests?).to be_falsey
      end
    end
  end
end
