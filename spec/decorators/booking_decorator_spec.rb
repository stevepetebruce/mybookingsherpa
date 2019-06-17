require "rails_helper"

RSpec.describe BookingDecorator, type: :model do

  let!(:booking) { FactoryBot.create(:booking, guest: guest) }
  let(:guest) { FactoryBot.create(:guest) }

  describe "#dynamically created fallback fields" do
    subject(:dynamic_value) { described_class.new(booking).send(dynamically_created_field) }

    let!(:dynamically_created_field) { Guest::UPDATABLE_FIELDS.sample }

    context "a guest that does not have a name yet, but their most recent booking does" do
      let!(:booking) { FactoryBot.create(:booking, :all_fields_complete, guest: guest) }

      it "should return the booking name" do
        expect(dynamic_value).to eq booking.send(dynamically_created_field)
      end
    end
  end

  describe "#flag_icon" do
    subject { described_class.new(booking).flag_icon }

    let!(:country_code) { Faker::Address.country_code }

    context "a booking with a country code" do
      before { allow(booking).to receive(:country).and_return(country_code) }

      it "should return expected flag-icon class" do
        expect(subject).to eq "flag-icon-#{country_code.downcase}"
      end
    end

    context "a booking with a guest with a country code" do
      before { allow(guest).to receive(:country).and_return(country_code) }

      it "should return expected flag-icon class" do
        expect(subject).to eq "flag-icon-#{country_code.downcase}"
      end
    end

    context "a booking and guest without a country code" do
      it "should return nil" do
        expect(subject).to be_nil
      end
    end
  end

  describe "#full_payment_date" do
    subject(:full_payment_date) { described_class.new(booking).full_payment_date }

    let!(:booking) { FactoryBot.create(:booking, guest: guest, trip: trip) }
    let(:trip) { FactoryBot.create(:trip, full_payment_window_weeks: rand(2...6)) }

    it "should be the trip_start_date - trip_full_payment_window_weeks" do
      expect(full_payment_date).to eq (booking.trip_start_date - booking.trip_full_payment_window_weeks.weeks).strftime("%F")
    end
  end

  describe "#gravatar_url" do
    subject { described_class.new(booking).gravatar_url }

    let(:gravatar_id) { Digest::MD5.hexdigest(booking.guest_email).downcase }

    it "should return expected URL" do
      expect(subject).to start_with "https://gravatar.com/avatar/#{gravatar_id}"
    end
  end

  describe "#human_readable_amount_due" do
    subject(:human_readable_amount_due) { described_class.new(booking).human_readable_amount_due }

    it "should be the currency of the trip and the cost now due" do
      expect(human_readable_amount_due).to eq "#{Currency.iso_to_symbol(booking.currency)}#{Currency.human_readable(booking.full_cost * 100)}"
    end
  end

  describe "#human_readable_full_cost" do
    subject(:human_readable_full_cost) { described_class.new(booking).human_readable_full_cost }

    it "should be the currency of the trip and the full cost" do
      expect(human_readable_full_cost).to eq "#{Currency.iso_to_symbol(booking.currency)}#{Currency.human_readable(booking.full_cost * 100)}"
    end
  end

  describe "#only_paying_deposit?" do
    subject(:only_paying_deposit?) { described_class.new(booking).only_paying_deposit? }

    context "when only deposit is due to be paid" do
      before do
        allow(Bookings::Payment).to receive(:amount_due).with(booking).and_return(booking.deposit_cost)
      end

      it "should be true" do
        expect(only_paying_deposit?).to be true
      end
    end

    context "when full amount is due to be paid" do
      before do
        allow(Bookings::Payment).to receive(:amount_due).with(booking).and_return(booking.full_cost)
      end

      it "should be true" do
        expect(only_paying_deposit?).to be false
      end
    end
  end

  describe "#status" do
    subject(:status) { described_class.new(booking).status(trip) }

    let(:trip) { FactoryBot.create(:trip) }

    context "booking is incomplete / yellow" do
      let!(:booking) { FactoryBot.create(:booking, guest: guest, trip: trip) }

      it "should return the correct flag" do
        expect(status).to eq "dot-warning"
      end
    end

    context "booking is complete / green" do
      let(:booking) { FactoryBot.create(:booking, :all_fields_complete, guest: guest, trip: trip) }
      let!(:payment) { FactoryBot.create(:payment, amount: booking.full_cost, booking: booking) }

      before { booking.update(updated_at: Time.zone.now) }

      it "should return the correct flag" do
        expect(status).to eq "dot-success"
      end
    end
  end

  describe "#status_alert?" do
    subject(:status_alert?) { described_class.new(booking).status_alert? }

    let(:trip) { FactoryBot.create(:trip) }

    context "booking has incomplete personal details" do
      let!(:booking) { FactoryBot.create(:booking, guest: guest, trip: trip) }

      it { expect(status_alert?).to eq true }
    end

    context "booking has complete booking details but requires payment" do
      let!(:booking) { FactoryBot.create(:booking, :all_fields_complete, guest: guest, trip: trip) }

      it { expect(status_alert?).to eq true }
    end

    context "payment complete" do
      let!(:payment) { FactoryBot.create(:payment, amount: booking.full_cost, booking: booking) }

      context "booking has complete booking details" do
        let(:booking) { FactoryBot.create(:booking, :complete_without_any_issues, guest: guest, trip: trip) }

        it { expect(status_alert?).to eq false }
      end

      context "booking has complete booking details and has allergies" do
        let(:booking) { FactoryBot.create(:booking, :complete_with_allergies, guest: guest, trip: trip) }

        it { expect(status_alert?).to eq true }
      end

      context "booking has complete booking details and has dietary requirements" do
        let(:booking) { FactoryBot.create(:booking, :complete_with_dietary_requirements, guest: guest, trip: trip) }

        it { expect(status_alert?).to eq true }
      end

      context "booking has complete booking details and has other_information" do
        let(:booking) { FactoryBot.create(:booking, :complete_with_other_information, guest: guest, trip: trip) }

        it { expect(status_alert?).to eq true }
      end
    end
  end

  describe "#status_text" do
    subject(:status_text) { described_class.new(booking).status_text }

    let(:trip) { FactoryBot.create(:trip) }

    context "payment required" do
      context "booking has incomplete personal details" do
        let!(:booking) { FactoryBot.create(:booking, guest: guest, trip: trip) }

        it { expect(status_text).to eq "Payment required" }
      end

      context "booking has complete booking details but requires payment" do
        let!(:booking) { FactoryBot.create(:booking, :all_fields_complete, guest: guest, trip: trip) }

        it { expect(status_text).to eq "Payment required" }
      end
    end

    context "payment complete" do
      let!(:payment) { FactoryBot.create(:payment, amount: booking.full_cost, booking: booking) }

      context "booking has incomplete personal details" do
        let!(:booking) { FactoryBot.create(:booking, guest: guest, trip: trip) }

        it { expect(status_text).to eq "Incomplete booking details" }
      end

      context "booking has complete booking details" do
        let(:booking) { FactoryBot.create(:booking, :complete_without_any_issues, guest: guest, trip: trip) }

        it { expect(status_text).to be_nil }
      end

      context "booking has complete booking details and has allergies" do
        let(:booking) { FactoryBot.create(:booking, :complete_with_allergies, guest: guest, trip: trip) }

        it { expect(status_text).to eq "Allergies" }
      end

      context "booking has complete booking details and has dietary requirements" do
        let(:booking) { FactoryBot.create(:booking, :complete_with_dietary_requirements, guest: guest, trip: trip) }

        it { expect(status_text).to eq "Dietary requirements" }
      end

      context "booking has complete booking details and has other_information" do
        let(:booking) { FactoryBot.create(:booking, :complete_with_other_information, guest: guest, trip: trip) }

        it { expect(status_text).to eq "Other information" }
      end
    end
  end

  describe "#stripe_publishable_key" do
    subject(:stripe_publishable_key) { described_class.new(booking).stripe_publishable_key }
    let(:organisation) { booking.organisation }

    context "organisation that is on a trial" do
      it "should return the Stripe test API key" do
        allow(organisation).to receive(:on_trial?).and_return(true)
        expect(stripe_publishable_key).to eq ENV.fetch("STRIPE_PUBLISHABLE_KEY_TEST")
      end
    end

    context "organisation that is on a trial" do
      it "should return the Stripe test API key" do
        allow(organisation).to receive(:on_trial?).and_return(false)
        expect(stripe_publishable_key).to eq ENV.fetch("STRIPE_PUBLISHABLE_KEY_LIVE")
      end
    end
  end
end
