require "rails_helper"

RSpec.describe Bookings::PaymentStatus, type: :model do
  let(:booking) { FactoryBot.create(:booking) }

  describe "#new_payment_status?" do
    subject(:new_payment_status) { described_class.new(booking).new_payment_status }

    context "a booking with no payments" do
      it "should set the booking's new_payment_status to yellow" do
        expect(new_payment_status).to eq :payment_required
      end
    end

    context "a booking that has paid the deposit for the trip" do
      let(:deposit_amount) { booking.full_cost * 0.5 }
      let!(:payment) { FactoryBot.create(:payment, amount: deposit_amount, booking: booking) }

      it "should set the booking's new_payment_status to yellow" do
        expect(new_payment_status).to eq :payment_required
      end
    end

    context "a booking whose last payment failed" do
      let!(:payment) { FactoryBot.create(:payment, :failed, booking: booking) }

      it "should set the booking's new_payment_status to red" do
        expect(new_payment_status).to eq :payment_failed
      end
    end
  end
end
