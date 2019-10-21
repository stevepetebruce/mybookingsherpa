require "rails_helper"

RSpec.describe Bookings::PaymentIntents, type: :model do
  describe "#create" do
    subject(:create) { described_class.create(booking) }

    let!(:booking) { FactoryBot.create(:booking) }

    context "successful" do
      before do
        stub_request(:post, "https://api.stripe.com/v1/payment_intents").
          with(body: {
            amount: booking.full_cost,
            application_fee_amount: Bookings::PaymentIntents::REGULAR_DESTINATION_FEE,
            currency: booking.currency,
            setup_future_usage: "on_session",
            statement_descriptor: booking.trip_name.truncate(22, separator: " "),
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

      context "organisation on trial" do
        let(:attributes) do
          {
            amount: booking.full_cost,
            application_fee_amount: Bookings::PaymentIntents::REGULAR_DESTINATION_FEE,
            currency: booking.currency,
            customer: nil,
            setup_future_usage: "on_session",
            statement_descriptor: booking.trip_name.truncate(22, separator: " "),
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
            application_fee_amount: Bookings::PaymentIntents::REGULAR_DESTINATION_FEE,
            currency: booking.currency,
            customer: nil,
            setup_future_usage: "on_session",
            statement_descriptor: booking.trip_name.truncate(22, separator: " "),
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
    end
  end

  # TODO: this is really a total duplicate of the #create method - need to look at this...
  describe "#find_or_create" do
    subject(:find_or_create) { described_class.find_or_create(booking) }

    let!(:booking) { FactoryBot.create(:booking) }

    context "successful" do
      before do
        stub_request(:post, "https://api.stripe.com/v1/payment_intents").
          with(body: {
            amount: booking.full_cost,
            application_fee_amount: Bookings::PaymentIntents::REGULAR_DESTINATION_FEE,
            currency: booking.currency,
            setup_future_usage: "on_session",
            statement_descriptor: booking.trip_name.truncate(22, separator: " "),
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
            application_fee_amount: Bookings::PaymentIntents::REGULAR_DESTINATION_FEE,
            currency: booking.currency,
            customer: nil,
            setup_future_usage: "on_session",
            statement_descriptor: booking.trip_name.truncate(22, separator: " "),
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
            application_fee_amount: Bookings::PaymentIntents::REGULAR_DESTINATION_FEE,
            currency: booking.currency,
            customer: nil,
            setup_future_usage: "on_session",
            statement_descriptor: booking.trip_name.truncate(22, separator: " "),
            transfer_data: { destination: booking.organisation_stripe_account_id }
          }
        end

        before { allow(booking).to receive(:organisation_on_trial?).and_return(false) }

        it "should call External::StripeApi::PaymentIntent#create with the correct attributes" do
          expect(External::StripeApi::PaymentIntent).to receive(:create).with(attributes, use_test_api: false)

          find_or_create
        end
      end
    end
  end
end
