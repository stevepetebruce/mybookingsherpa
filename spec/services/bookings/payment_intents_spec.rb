require "rails_helper"

RSpec.describe Bookings::PaymentIntents, type: :model do
  describe "#create" do
    subject(:create) { described_class.create(booking) }

    let!(:booking) { FactoryBot.create(:booking, organisation: organisation, trip: trip) }
    let(:organisation) { FactoryBot.create(:organisation, :on_regular_plan) }
    let(:trip) { FactoryBot.create(:trip) }

    context "successful" do
      before do
        stub_request(:post, "https://api.stripe.com/v1/payment_intents").
          with(body: {
            amount: booking.full_cost,
            application_fee_amount: (booking.full_cost * 0.01).to_i,
            currency: booking.currency,
            setup_future_usage: "on_session",
            statement_descriptor_suffix: booking.trip_name.truncate(22, separator: " ").gsub(/[^a-zA-Z\s\\.]/, "_"),
            transfer_data: { destination: booking.organisation_stripe_account_id }
          }).
          to_return(status: 200,
                    body: "#{file_fixture("stripe_api/successful_payment_intent.json").read}",
                    headers: {})
      end

      it "should not raise an exception" do
        expect { create }.to_not raise_exception
      end

      it "should return something other than nil" do
        expect(create).to_not be_nil
      end

      context "when only paying deposit" do
        let(:trip) do 
          FactoryBot.create(:trip,
                            :with_deposit,
                            start_date: 4.weeks.from_now,
                            end_date: 5.weeks.from_now,
                            full_payment_window_weeks: 1)
        end

        let(:attributes) do
          {
            amount: booking.deposit_cost,
            currency: booking.currency,
            customer: nil,
            setup_future_usage: "off_session",
            statement_descriptor_suffix: booking.trip_name.truncate(22, separator: " ").gsub(/[^a-zA-Z\s\\.]/, "_"),
            transfer_data: { destination: booking.organisation_stripe_account_id }
          }
        end

        it "should not charge an application_fee" do
          expect(External::StripeApi::PaymentIntent).to receive(:create).with(attributes, use_test_api: true)

          create
        end
      end

      context "organisation on trial" do
        let(:attributes) do
          {
            amount: booking.full_cost,
            application_fee_amount: (booking.full_cost * 0.01).to_i,
            currency: booking.currency,
            customer: nil,
            setup_future_usage: "on_session",
            statement_descriptor_suffix: booking.trip_name.truncate(22, separator: " ").gsub(/[^a-zA-Z\s\\.]/, "_"),
            transfer_data: { destination: booking.organisation_stripe_account_id }
          }
        end

        it "should call External::StripeApi::PaymentIntent#create with the correct attributes" do
          expect(External::StripeApi::PaymentIntent).to receive(:create).with(attributes, use_test_api: true)

          create
        end
      end

      context "organisation not on trial" do
        let(:attributes) do
          {
            amount: booking.full_cost,
            application_fee_amount: (booking.full_cost * 0.01).to_i,
            currency: booking.currency,
            customer: nil,
            setup_future_usage: "on_session",
            statement_descriptor_suffix: booking.trip_name.truncate(22, separator: " ").gsub(/[^a-zA-Z\s\\.]/, "_"),
            transfer_data: { destination: booking.organisation_stripe_account_id }
          }
        end

        before { allow(booking).to receive(:organisation_on_trial?).and_return(false) }

        it "should call External::StripeApi::PaymentIntent#create with the correct attributes" do
          expect(External::StripeApi::PaymentIntent).to receive(:create).with(attributes, use_test_api: false)

          create
        end
      end

      # TODO: also need to test when paying deposit.
      # When the application_fee_amount == 0. 
      # It is now rejected - as it was breaking the call to Stripe
    end
  end

  describe "#find_or_create" do
    subject(:find_or_create) { described_class.find_or_create(booking) }

    let!(:booking) { FactoryBot.create(:booking, organisation: organisation) }
    let(:organisation) { FactoryBot.create(:organisation, :on_regular_plan) }

    context "successful" do
      before do
        stub_request(:post, "https://api.stripe.com/v1/payment_intents").
          with(body: {
            amount: booking.full_cost,
            application_fee_amount: (booking.full_cost * 0.01).to_i,
            currency: booking.currency,
            setup_future_usage: "on_session",
            statement_descriptor_suffix: booking.trip_name.truncate(22, separator: " ").gsub(/[^a-zA-Z\s\\.]/, "_"),
            transfer_data: { destination: booking.organisation_stripe_account_id }
          }).
          to_return(status: 200,
                    body: "#{file_fixture("stripe_api/successful_payment_intent.json").read}",
                    headers: {})
      end

      it "should not raise an exception" do
        expect { find_or_create }.to_not raise_exception
      end

      it "should return something other than nil" do
        expect(find_or_create).to_not be_nil
      end

      context "organisation on trial" do
        let(:attributes) do
          {
            amount: booking.full_cost,
            application_fee_amount: (booking.full_cost * 0.01).to_i,
            currency: booking.currency,
            customer: nil,
            setup_future_usage: "on_session",
            statement_descriptor_suffix: booking.trip_name.truncate(22, separator: " ").gsub(/[^a-zA-Z\s\\.]/, "_"),
            transfer_data: { destination: booking.organisation_stripe_account_id }
          }
        end

        it "should call External::StripeApi::PaymentIntent#create with the correct attributes" do
          expect(External::StripeApi::PaymentIntent).to receive(:create).with(attributes, use_test_api: true)

          find_or_create
        end
      end

      context "organisation not on trial" do

        let(:attributes) do
          {
            amount: booking.full_cost,
            application_fee_amount: (booking.full_cost * 0.01).to_i,
            currency: booking.currency,
            customer: nil,
            setup_future_usage: "on_session",
            statement_descriptor_suffix: booking.trip_name.truncate(22, separator: " ").gsub(/[^a-zA-Z\s\\.]/, "_"),
            transfer_data: { destination: booking.organisation_stripe_account_id }
          }
        end

        before { allow(booking).to receive(:organisation_on_trial?).and_return(false) }

        it "should call External::StripeApi::PaymentIntent#create with the correct attributes" do
          expect(External::StripeApi::PaymentIntent).to receive(:create).with(attributes, use_test_api: false)

          find_or_create
        end
      end

      context "last payment (intent) failed" do
        let!(:payment) do 
          FactoryBot.create(:payment,
                            :failed,
                            booking: booking,
                            stripe_payment_intent_id: stripe_payment_intent_id)
        end
        let!(:stripe_payment_intent_id) { "cus_#{Faker::Crypto.md5}" }

        before { allow(External::StripeApi::PaymentIntent).to receive(:retrieve) }

        it "should call External::StripeApi::PaymentIntent.retrieve" do
          find_or_create

          expect(External::StripeApi::PaymentIntent).to have_received(:retrieve).with(stripe_payment_intent_id, use_test_api: true)
        end
      end
    end
  end
end
