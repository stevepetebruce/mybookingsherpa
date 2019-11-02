require "rails_helper"

RSpec.describe Bookings::PayOutstandingTripCostJob, type: :job do
  before { ActiveJob::Base.queue_adapter = :inline }

  describe "#perform_later" do
    subject(:perform_later) { described_class.perform_later(booking) }

    let!(:booking) { FactoryBot.create(:booking, guest: guest) }
    let(:guest) { FactoryBot.create(:guest, stripe_customer_id: stripe_customer_id) }
    let!(:stripe_customer_id) { "cus_#{Faker::Crypto.md5}" }

    before do
      stub_request(:post, "https://api.stripe.com/v1/payment_intents").
        with(body: {
            amount: booking.full_cost,
            # TODO: application_fee_amount: Bookings::PaymentIntents::REGULAR_DESTINATION_FEE,
            confirm: true,
            currency: booking.currency,
            customer: stripe_customer_id,
            metadata: {
              booking_id: booking.id
            },
            off_session: true,
            payment_method: "pm_1EUmyr2x6R10KRrhlYS3l97f",
            statement_descriptor: booking.trip_name.truncate(22, separator: " "),
          }).
        to_return(status: 200,
                  body: "#{file_fixture("stripe_api/successful_payment_intent.json").read}",
                  headers: {})

      stub_request(:get, "https://api.stripe.com/v1/payment_methods?type=card").
        to_return(status: 200,
                  body: "#{file_fixture("stripe_api/successful_payment_method.json").read}",
                  headers: {})

      stub_request(:get, "https://api.stripe.com/v1/payment_methods?customer=#{stripe_customer_id}&type=card").
        to_return(status: 200,
                  body: "#{file_fixture("stripe_api/successful_payment_methods_list.json").read}",
                  headers: {})
    end

    context "booking whose full_payment is required" do
      before do
        allow_any_instance_of(Bookings::PaymentStatus).
          to receive(:payment_required?).
          and_return(true)
      end

      let(:payment_required?) { true }

      it "should create a charge" do
        pending 'this should be done in the webhook now'
        expect { perform_later }.to change { booking.payments.count }.from(0).to(1)
      end
    end

    context "booking whose full_payment is not required" do
      before do
        allow_any_instance_of(Bookings::PaymentStatus).
          to receive(:payment_required?).
          and_return(false)
      end

      let(:payment_required?) { true }

      it "should not create a charge" do
        expect { perform_later }.to_not change { booking.payments.count }
      end
    end

    context "booking whose full_payment is required but card payment fails" do
      before do
        allow_any_instance_of(Bookings::PaymentStatus).
          to receive(:payment_required?).
          and_return(true)

        allow(Stripe::Charge).to receive(:create).
          and_raise(Stripe::CardError.new("Card declined", nil, json_body: { error: { message: "Card declined" } }))
      end

      let(:payment_required?) { true }

      it "should create a charge with a failed status" do
        pending 'this should be done in the webhook now'
        expect { perform_later }.to change { booking.payments.count }.from(0).to(1)
        expect(booking.last_payment_failed?).to be_truthy
      end
    end

    context "booking whose full_payment is required but there's a generic StripeError" do
      before do
        allow_any_instance_of(Bookings::PaymentStatus).
          to receive(:payment_required?).
          and_return(true)

        allow(Stripe::Charge).to receive(:create).
          and_raise(Stripe::APIConnectionError.new)
      end

      let(:payment_required?) { true }

      it "should create a charge with a failed status" do
        pending 'this should be done in the webhook now'
        expect { perform_later }.to change { booking.payments.count }.from(0).to(1)
        expect(booking.last_payment_failed?).to be_truthy
      end
    end
  end
end