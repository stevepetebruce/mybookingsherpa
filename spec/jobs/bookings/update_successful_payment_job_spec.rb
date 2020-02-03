require "rails_helper"

RSpec.describe Bookings::UpdateSuccessfulPaymentJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.perform_in(15.minutes, amount, stripe_payment_intent_id) }

    context "payment with associated booking" do
      let!(:amount) { booking.full_cost }
      let(:booking) { FactoryBot.create(:booking) }
      let!(:payment) do
        FactoryBot.create(:payment,
                          :pending,
                          booking: booking,
                          stripe_payment_intent_id: stripe_payment_intent_id)
      end
      let!(:stripe_payment_intent_id) { "pi_#{Faker::Crypto.md5}" }

      it "should update the payment" do
        perform

        expect(payment.reload.status).to eq "success"
        expect(payment.amount).to eq amount
      end
    end

    context "payment without associated booking" do
      let!(:amount) { Faker::Number.between(50_000, 100_000) }
      let!(:payment) do
        FactoryBot.create(:payment,
                          :pending,
                          amount: amount,
                          booking: nil,
                          stripe_payment_intent_id: stripe_payment_intent_id)
      end
      let!(:stripe_payment_intent_id) { "pi_#{Faker::Crypto.md5}" }

      let(:expected_message) {  }

      it "should raise a Bookings::PaymentWithoutBookingError" do
        expect{ perform }.
          to raise_error(Bookings::PaymentWithoutBookingError).
          with_message(/Attempted to create a payment without an associated booking/)
      end
    end
  end
end
