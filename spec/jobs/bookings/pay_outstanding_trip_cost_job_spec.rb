require "rails_helper"

RSpec.describe Bookings::PayOutstandingTripCostJob, type: :job do
  before { ActiveJob::Base.queue_adapter = :inline }

  describe "#perform" do
    subject(:perform) { described_class.new.perform(booking.id) }

    let!(:booking) { FactoryBot.create(:booking, trip: trip, organisation: organisation, stripe_customer_id: stripe_customer_id, stripe_payment_method_id: stripe_payment_method_id) }
    let(:deposit_amount) { booking.full_cost * (deposit_percentage.to_f / 100) }
    let(:deposit_percentage) { Faker::Number.between(1, 50) }
    let(:organisation) { FactoryBot.create(:organisation, :on_regular_plan) }
    let!(:stripe_customer_id) { "cus_#{Faker::Crypto.md5}" }
    let!(:stripe_payment_method_id) { "pm_#{Faker::Crypto.md5}" }
    let(:trip) do
      FactoryBot.create(:trip,
                        deposit_percentage: deposit_percentage,
                        full_payment_window_weeks: 1)
    end

    before do
      stub_request(:post, "https://api.stripe.com/v1/payment_intents").
        with(body: {
            amount: booking.full_cost,
            application_fee_amount: (booking.full_cost * 0.01).to_i,
            confirm: true,
            currency: booking.currency,
            customer: stripe_customer_id,
            metadata: {
              base_domain: ENV.fetch("BASE_DOMAIN"),
              booking_id: booking.id
            },
            off_session: true,
            payment_method: booking.stripe_payment_method_id,
            statement_descriptor_suffix: booking.trip_name.truncate(22, separator: " ").gsub(/[^a-zA-Z\s\\.]/, "_"),
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

      FactoryBot.create(:payment, :success, amount: deposit_amount, booking: booking)
    end

    context "booking whose full_payment is required" do
      before do
        allow_any_instance_of(Bookings::PaymentStatus).
          to receive(:payment_required?).
          and_return(true)

        allow(External::StripeApi::PaymentIntent).to receive(:create).and_return(double(id: "pi_#{Faker::Crypto.md5}"))
      end

      let(:payment_required?) { true }

      let(:expected_attributes) do
        {
          amount: booking.full_cost,
          application_fee_amount: (booking.full_cost * 0.01).to_i,
          confirm: true,
          currency: booking.currency,
          customer: stripe_customer_id,
          metadata: {
            base_domain: ENV.fetch("BASE_DOMAIN"),
            booking_id: booking.id
          },
          off_session: true,
          payment_method: booking.stripe_payment_method_id,
          statement_descriptor_suffix: booking.trip_name.truncate(22, separator: " ").gsub(/[^a-zA-Z\s\\.]/, "_"),
        }
      end

      it "should call External::StripeApi::PaymentIntent#create" do
        perform
        binding.pry
        expect(External::StripeApi::PaymentIntent).
          to have_received(:create).
          with(expected_attributes, organisation.stripe_account_id, use_test_api: true)
      end
    end

    context "booking whose full_payment is not required" do
      before do
        allow_any_instance_of(Bookings::PaymentStatus).
          to receive(:payment_required?).
          and_return(false)

        allow(External::StripeApi::PaymentIntent).to receive(:create)
      end

      let(:payment_required?) { true }

      it "should not call External::StripeApi::PaymentIntent#create" do
        perform

        expect(External::StripeApi::PaymentIntent).not_to have_received(:create)
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
        # TODO: need to look at this... needs manual testing....
        # https://stripe.com/docs/testing#three-ds-cards: 4000008400001629
        pending 'this should be done in the webhook now'
        expect { perform }.to change { booking.payments.count }.from(0).to(1)
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
        expect { perform }.to change { booking.payments.count }.from(0).to(1)
        expect(booking.last_payment_failed?).to be_truthy
      end
    end
  end
end
