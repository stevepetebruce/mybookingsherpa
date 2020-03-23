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

  describe "#guest_or_booking_allergies" do
    subject(:guest_or_booking_allergies) { booking.guest_or_booking_allergies }

    context "a booking / guest without any allergies" do
      it "should return an empty array" do
        expect(guest_or_booking_allergies).to eq []
      end
    end

    context "a booking with allergies" do
      let!(:allergy) { FactoryBot.create(:allergy, allergic: booking) }

      it "should return an array including the allergy" do
        expect(guest_or_booking_allergies).to include(allergy)
      end
    end

    context "a guest with allergies" do
      let!(:allergy) { FactoryBot.create(:allergy, allergic: guest) }

      it "should return an array including the allergy" do
        expect(guest_or_booking_allergies).to include(allergy)
      end
    end

    context "a guest and a booking with allergies" do
      let!(:booking_allergy) { FactoryBot.create(:allergy, allergic: booking) }
      let!(:guest_allergy) { FactoryBot.create(:allergy, allergic: guest) }

      it "should return an array including the guests' allergy (prioritised over the booking allergy)" do
        expect(guest_or_booking_allergies).to include(guest_allergy)
        expect(guest_or_booking_allergies).to_not include(booking_allergy)
      end
    end
  end

  describe "#guest_or_booking_allergies?" do
    subject(:guest_or_booking_allergies?) { booking.guest_or_booking_allergies? }

    context "a booking / guest without any allergies" do
      it "should be false" do
        expect(guest_or_booking_allergies?).to be_falsey
      end
    end

    context "a booking with allergies" do
      let!(:allergy) { FactoryBot.create(:allergy, allergic: booking) }

      it "should be true" do
        expect(guest_or_booking_allergies?).to be_truthy
      end
    end

    context "a guest with allergies" do
      let!(:allergy) { FactoryBot.create(:allergy, allergic: guest) }

      it "should be true" do
        expect(guest_or_booking_allergies?).to be_truthy
      end
    end
  end

  describe "#human_readable_allergies" do
    subject(:human_readable_allergies) { booking.human_readable_allergies }

    context "a booking / guest without any allergies" do
      it "should return an empty string" do
        expect(human_readable_allergies).to eq ""
      end
    end

    context "a booking with allergies" do
      let!(:allergy) { FactoryBot.create(:allergy, allergic: booking) }

      it "should return a human_readable version of the booking allergy's name" do
        expect(human_readable_allergies).to eq allergy.name.capitalize
      end
    end

    context "a guest with allergies" do
      let!(:allergy) { FactoryBot.create(:allergy, allergic: guest) }

      it "should return a human_readable version of the guest allergy's name" do
        expect(human_readable_allergies).to eq allergy.name.capitalize
      end
    end

    context "a guest and a booking with allergies" do
      let!(:booking_allergy) { FactoryBot.create(:allergy, name: "dairy", allergic: booking) }
      let!(:guest_allergy) { FactoryBot.create(:allergy, name: "nuts", allergic: guest) }

      it "should return a human_readable version of the guest allergy's name (prioritised over the booking allergy)" do
        expect(human_readable_allergies).to eq guest_allergy.name.capitalize
        expect(human_readable_allergies).to_not include(booking_allergy.name.capitalize)
      end
    end
  end

  describe "#guest_or_booking_dietary_requirements" do
    subject(:guest_or_booking_dietary_requirements) { booking.guest_or_booking_dietary_requirements }

    context "a booking / guest without any dietary_requirements" do
      it "should return an empty array" do
        expect(guest_or_booking_dietary_requirements).to eq []
      end
    end

    context "a booking with dietary_requirements" do
      let!(:dietary_requirements) { FactoryBot.create(:dietary_requirement, dietary_requirable: booking) }

      it "should return an array including the dietary_requirements" do
        expect(guest_or_booking_dietary_requirements).to include(dietary_requirements)
      end
    end

    context "a guest with dietary_requirements" do
      let!(:dietary_requirements) { FactoryBot.create(:dietary_requirement, dietary_requirable: guest) }

      it "should return an array including the dietary_requirements" do
        expect(guest_or_booking_dietary_requirements).to include(dietary_requirements)
      end
    end

    context "a guest and a booking with dietary_requirements" do
      let!(:booking_dietary_requirements) { FactoryBot.create(:dietary_requirement, dietary_requirable: booking) }
      let!(:guest_dietary_requirements) { FactoryBot.create(:dietary_requirement, dietary_requirable: guest) }

      it "should return an array including the guests' dietary_requirements (prioritised over the booking dietary_requirements)" do
        expect(guest_or_booking_dietary_requirements).to include(guest_dietary_requirements)
        expect(guest_or_booking_dietary_requirements).to_not include(booking_dietary_requirements)
      end
    end
  end

  describe "#guest_or_booking_dietary_requirements?" do
    subject(:guest_or_booking_dietary_requirements?) { booking.guest_or_booking_dietary_requirements? }

    context "a booking / guest without any dietary_requirements" do
      it "should be false" do
        expect(guest_or_booking_dietary_requirements?).to be_falsey
      end
    end

    context "a booking with dietary_requirements" do
      let!(:dietary_requirements) { FactoryBot.create(:dietary_requirement, dietary_requirable: booking) }

      it "should be true" do
        expect(guest_or_booking_dietary_requirements?).to be_truthy
      end
    end

    context "a guest with dietary_requirements" do
      let!(:dietary_requirements) { FactoryBot.create(:dietary_requirement, dietary_requirable: guest) }

      it "should be true" do
        expect(guest_or_booking_dietary_requirements?).to be_truthy
      end
    end
  end

  describe "#human_readable_dietary_requirements" do
    subject(:human_readable_dietary_requirements) { booking.human_readable_dietary_requirements }

    context "a booking / guest without any dietary_requirements" do
      it "should return an empty string" do
        expect(human_readable_dietary_requirements).to eq ""
      end
    end

    context "a booking with dietary_requirements" do
      let!(:dietary_requirements) { FactoryBot.create(:dietary_requirement, dietary_requirable: booking) }

      it "should return a human_readable version of the booking dietary_requirements's name" do
        expect(human_readable_dietary_requirements).to eq dietary_requirements.name.capitalize
      end
    end

    context "a guest with dietary_requirements" do
      let!(:dietary_requirements) { FactoryBot.create(:dietary_requirement, dietary_requirable: guest) }

      it "should return a human_readable version of the guest dietary_requirements's name" do
        expect(human_readable_dietary_requirements).to eq dietary_requirements.name.capitalize
      end
    end

    context "a guest and a booking with dietary_requirements" do
      let!(:booking_dietary_requirements) { FactoryBot.create(:dietary_requirement, name: "other", dietary_requirable: booking) }
      let!(:guest_dietary_requirements) { FactoryBot.create(:dietary_requirement, name: "vegan", dietary_requirable: guest) }

      it "should return a human_readable version of the guest dietary_requirements's name (prioritised over the booking dietary_requirements)" do
        expect(human_readable_dietary_requirements).to eq guest_dietary_requirements.name.capitalize
        expect(human_readable_dietary_requirements).to_not include(booking_dietary_requirements.name.capitalize)
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

  describe "#human_readable_full_cost_minus_deposit" do
    subject(:human_readable_full_cost_minus_deposit) { booking.human_readable_full_cost_minus_deposit }

    context "a trip with a deposit amount" do
      let!(:booking) { FactoryBot.create(:booking, trip: trip) }
      let!(:deposit_percentage) { Faker::Number.between(from: 10, to: 25) }
      let!(:full_cost) { Faker::Number.between(from: 5000, to: 10_000) }
      let(:outstanding_amount) { trip.full_cost - trip.deposit_cost }
      let!(:trip) do
        FactoryBot.create(:trip,
                          deposit_percentage: deposit_percentage,
                          full_cost: full_cost,
                          full_payment_window_weeks: Faker::Number.between(from: 1, to: 10))
      end

      it "should return the correct value" do
        expect(human_readable_full_cost_minus_deposit).to eq "#{Currency.iso_to_symbol(booking.currency)}#{Currency.human_readable(outstanding_amount)}"
      end
    end

    context "a trip without a deposit amount" do
      it "should return an empty string" do
        expect(human_readable_full_cost_minus_deposit).to eq ""
      end
    end
  end

  describe "#human_readable_full_payment_date" do
    let!(:booking) { FactoryBot.create(:booking, guest: guest, trip: trip) }
    subject(:human_readable_full_payment_date) { booking.human_readable_full_payment_date }

    context "trip with a full_payment_date" do
      let!(:full_payment_window_weeks) { Faker::Number.between(from: 5, to: 10) }
      let(:trip) do
        FactoryBot.create(:trip,
                          deposit_percentage: Faker::Number.between(from: 10, to: 50),
                          full_payment_window_weeks: full_payment_window_weeks)
      end

      it "should return the corect date in the correct format" do
        expect(human_readable_full_payment_date).to match(/\A[0-9]{2}-[0-9]{2}-[0-9]{4}\z/)
      end
    end

    context "trip without a full_payment_date" do
      let(:trip) { FactoryBot.create(:trip, full_payment_window_weeks: nil) }

      it "should (safely) nil" do
        expect(human_readable_full_payment_date).to eq ""
      end
    end
  end

  describe "#only_paid_deposit?" do
    subject(:only_paid_deposit?) { booking.only_paid_deposit? }
    # TODO:
    # Test that if there's no deposit and or no payments (ie: either are nil) that this will be false
  end

  describe "#only_paying_deposit?" do
    subject(:only_paying_deposit?) { booking.only_paying_deposit? }

    context "when only deposit is due to be paid" do
      before do
        allow(Bookings::CostCalculator).to receive(:amount_due).with(booking).and_return(booking.deposit_cost)
      end

      it "should be true" do
        expect(only_paying_deposit?).to be true
      end
    end

    context "when full amount is due to be paid" do
      before do
        allow(Bookings::CostCalculator).to receive(:amount_due).with(booking).and_return(booking.full_cost)
      end

      it "should be true" do
        expect(only_paying_deposit?).to be false
      end
    end

    context "when the deposit is 50pc of the trip full cost and has been paid already" do
      let!(:booking) { FactoryBot.create(:booking, trip: trip) }
      let!(:deposit_percentage) { 50 }
      let!(:full_cost) { Faker::Number.between(from: 5000, to: 10_000) }
      let!(:payment) { FactoryBot.create(:payment, :success, amount: booking.deposit_cost, booking: booking) }
      let!(:trip) do
        FactoryBot.create(:trip,
                          deposit_percentage: deposit_percentage,
                          full_cost: full_cost,
                          full_payment_window_weeks: Faker::Number.between(from: 1, to: 10))
      end


      it "should be false" do
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

    context "booking's payment is pending / yellow" do
      let!(:payment) { FactoryBot.create(:payment, :pending, booking: booking) }

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
      let!(:payment) { FactoryBot.create(:payment, :success, amount: booking.full_cost, booking: booking) }

      it "should return the correct flag" do
        expect(payment_status_icon).to eq "dot-success"
      end
    end

    context "booking is refunded" do
      let!(:booking) { FactoryBot.create(:booking, payment_status: :refunded, guest: guest) }

      it "should return the correct flag" do
        expect(payment_status_icon).to eq "dot-danger"
      end
    end
  end

  describe "#payment_status_text" do
    subject(:payment_status_text) { booking.reload.payment_status_text }

    let!(:booking) { FactoryBot.create(:booking) }

    context "no payments have been made yet" do
      it { expect(payment_status_text).to eq "Deposit paid" }
    end

    context "payment is pending" do
      let!(:payment) { FactoryBot.create(:payment, :pending, amount: booking.full_cost, booking: booking) }

      it { expect(payment_status_text).to eq "Payment pending" }
    end

    context "payment complete" do
      let!(:payment) { FactoryBot.create(:payment, :success, amount: booking.full_cost, booking: booking) }

      it { expect(payment_status_text).to eq "Fully paid" }
    end

    context "last payment failed" do
      let!(:payment) { FactoryBot.create(:payment, :failed, booking: booking) }

      it { expect(payment_status_text).to eq "Last payment failed" }
    end

    context "last payment refunded" do
      let!(:booking) { FactoryBot.create(:booking, payment_status: :refunded, guest: guest) }

      it { expect(payment_status_text).to eq "Refunded" }
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
