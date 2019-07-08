require "rails_helper"

RSpec.describe BookingDecorator, type: :model do
  let!(:booking) { FactoryBot.create(:booking, guest: guest) }
  let(:guest) { FactoryBot.create(:guest) }

  describe "#dynamically created fallback fields" do
    subject(:dynamic_value) { booking.send(guest_or_booking_field) }

    let!(:dynamically_created_field) { Guest::UPDATABLE_FIELDS.sample }
    let!(:guest_or_booking_field) { "guest_or_booking_#{dynamically_created_field}" }

    context "a guest that does not have a name yet, but their most recent booking does" do
      let!(:booking) { FactoryBot.create(:booking, :all_fields_complete, guest: guest) }

      it "should return the booking's value for this field (not the guest's / nil)" do
        expect(dynamic_value).to eq booking.send(guest_or_booking_field)
      end
    end
  end

  describe "#flag_icon" do
    subject(:flag_icon) { booking.flag_icon }

    let!(:country_code) { Faker::Address.country_code }

    context "a booking with a country code" do
      before { allow(booking).to receive(:country).and_return(country_code) }

      it "should return expected flag-icon class" do
        expect(flag_icon).to eq "flag-icon-#{country_code.downcase}"
      end
    end

    context "a booking with a guest with a country code" do
      before { allow(guest).to receive(:country).and_return(country_code) }

      it "should return expected flag-icon class" do
        expect(flag_icon).to eq "flag-icon-#{country_code.downcase}"
      end
    end

    context "a booking and guest without a country code" do
      it "should return nil" do
        expect(flag_icon).to be_nil
      end
    end
  end

  describe "#gravatar_url" do
    subject(:gravatar_url) { booking.gravatar_url }

    let(:gravatar_id) { Digest::MD5.hexdigest(booking.guest_email).downcase }

    it "should return expected URL" do
      expect(gravatar_url).to start_with "https://gravatar.com/avatar/#{gravatar_id}"
    end
  end

  describe "#human_readable_full_payment_date" do
    let!(:booking) { FactoryBot.create(:booking, guest: guest, trip: trip) }
    subject(:human_readable_full_payment_date) { booking.human_readable_full_payment_date }

    context "trip with a full_payment_date" do
      let!(:full_payment_window_weeks) { Faker::Number.between(5, 10) }
      let(:trip) { FactoryBot.create(:trip, full_payment_window_weeks: full_payment_window_weeks) }

      it "should return the corfect date in the correct format" do
        expect(human_readable_full_payment_date).to match(/\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/)
      end
    end

    context "trip without a full_payment_date" do
      let(:trip) { FactoryBot.create(:trip, full_payment_window_weeks: nil) }

      it "should (safely) nil" do
        expect(human_readable_full_payment_date).to eq ""
      end
    end
  end

  describe "#human_readable_amount_due" do
    subject(:human_readable_amount_due) { booking.human_readable_amount_due }

    it "should be the currency of the trip and the cost now due" do
      expect(human_readable_amount_due).to eq "#{Currency.iso_to_symbol(booking.currency)}#{Currency.human_readable(booking.full_cost)}"
    end
  end

  describe "#human_readable_full_cost" do
    subject(:human_readable_full_cost) { booking.human_readable_full_cost }

    it "should be the currency of the trip and the full cost" do
      expect(human_readable_full_cost).to eq "#{Currency.iso_to_symbol(booking.currency)}#{Currency.human_readable(booking.full_cost)}"
    end
  end

  describe "#only_paying_deposit?" do
    subject(:only_paying_deposit?) { booking.only_paying_deposit? }

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

  describe "#payment_status_icon" do
    subject(:payment_status_icon) { booking.reload.payment_status_icon }

    let(:booking) { FactoryBot.create(:booking) }

    context "booking is not fully paid up / yellow" do
      it "should return the correct flag" do
        expect(payment_status_icon).to eq "dot-warning"
      end
    end

    context "booking's last payment failed / red" do
      let!(:payment) { FactoryBot.create(:payment, :failed, booking: booking) }

      it "should return the correct flag" do
        expect(payment_status_icon).to eq "dot-danger"
      end
    end

    context "booking is full paid up / green" do
      let!(:payment) { FactoryBot.create(:payment, amount: booking.full_cost, booking: booking) }

      it "should return the correct flag" do
        expect(payment_status_icon).to eq "dot-success"
      end
    end
  end

  describe "#payment_status_text" do
    subject(:payment_status_text) { booking.reload.payment_status_text }

    let!(:booking) { FactoryBot.create(:booking) }

    context "no payments have been made yet" do
      it { expect(payment_status_text).to eq "Payment required" }
    end

    context "payment complete" do
      let!(:payment) { FactoryBot.create(:payment, amount: booking.full_cost, booking: booking) }

      it { expect(payment_status_text).to eq "Fully paid" }
    end

    context "last payment failed" do
      let!(:payment) { FactoryBot.create(:payment, :failed, booking: booking) }
    end
  end

  describe "#stripe_publishable_key" do
    subject(:stripe_publishable_key) { booking.stripe_publishable_key }
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
