require "rails_helper"

RSpec.describe External::StripeApi::PaymentIntent, type: :model do
  describe "#create" do
    subject(:create) { described_class.create(attributes, stripe_account_id, use_test_api: use_test_api) }

    context "valid and successful" do
      let(:attributes) do
        {
          amount: Faker::Number.between(1_000, 10_000),
          application_fee_amount: [0, 200, 400].sample,
          currency: %w[eur, gbp, usd].sample,
          customer: "cus_#{Faker::Crypto.md5}",
          setup_future_usage: %w[off_session on_session].sample,
          statement_descriptor_suffix: Faker::Lorem.sentence.truncate(22, separator: " ").gsub(/[^a-zA-Z\s\\.]/, "_"),
          transfer_data:
            {
              destination: "acct_#{Faker::Bank.account_number(16)}"
            }
        }
      end
      let!(:stripe_account_id) { "acct_#{Faker::Bank.account_number(16)}" }
      let!(:use_test_api) { [true, false].sample }

      before do
        stub_request(:post, "https://api.stripe.com/v1/payment_intents").
          with(body: attributes).
          to_return(status: 200,
                    body: "#{file_fixture("stripe_api/successful_payment_intent.json").read}",
                    headers: {})
      end

      it "should call the Stripe PaymentIntents API with the correct attributes" do
        expect(Stripe::PaymentIntent).to receive(:create).with(attributes, stripe_account: stripe_account_id)

        create
      end

      context "a statement_descriptor_suffix with non-alphanumeric characters in" do
        let!(:amount) { Faker::Number.between(1_000, 10_000) }
        let!(:application_fee_amount) { [0, 200, 400].sample }
        let!(:currency) { %w[eur, gbp, usd].sample }
        let!(:customer) { "cus_#{Faker::Crypto.md5}" }
        let!(:destination) {  "acct_#{Faker::Bank.account_number(16)}" }
        let!(:stripe_account_id) { "acct_#{Faker::Bank.account_number(16)}" }

        let(:attributes) do
          {
            amount: amount,
            application_fee_amount: application_fee_amount,
            currency: currency,
            customer: customer,
            setup_future_usage: "off_session",
            statement_descriptor_suffix: "Ivy's Big Adventure Berlin 2017",
            transfer_data:
              {
                destination: destination
              }
          }
        end

        let(:sanitized_attributes) do
          {
            amount: amount,
            application_fee_amount: application_fee_amount,
            currency: currency,
            customer: customer,
            setup_future_usage: "off_session",
            statement_descriptor_suffix: "Ivy_s Big Adventure Berlin 2017",
            transfer_data:
              {
                destination: destination
              }
          }
        end

        it "should sanitize the attributes and make a successful call to the Stripe API" do
          expect(Stripe::PaymentIntent).to receive(:create).with(sanitized_attributes, stripe_account: stripe_account_id)

          create
        end
      end

      it "should return a Stripe PaymentIntent object" do
        # TODO: need to get a payment intent response and return it (may be using the wrong fixture ^)
      end
    end

    context "when the amount (owed/ to be paid) is zero" do
      let(:attributes) do
        {
          amount: 0,
          application_fee_amount: [0, 200, 400].sample,
          currency: %w[eur, gbp, usd].sample,
          customer: "cus_#{Faker::Crypto.md5}",
          setup_future_usage: %w[off_session on_session].sample,
          statement_descriptor_suffix: Faker::Lorem.sentence.truncate(22, separator: " ").gsub(/[^a-zA-Z\s\\.]/, "_"),
          transfer_data:
            {
              destination: "acct_#{Faker::Bank.account_number(16)}"
            }
        }
      end
      let!(:stripe_account_id) { "acct_#{Faker::Bank.account_number(16)}" }
      let!(:use_test_api) { [true, false].sample }

      it "should not make the call to Stripe (it's throws a Stripe::InvalidRequestError: Invalid positive integer)" do
        expect(Stripe::PaymentIntent).to_not receive(:create)

        create
      end
    end
  end

  describe "#retrieve" do
    subject(:retrieve) { described_class.retrieve(stripe_payment_intent_id, stripe_account_id, use_test_api: use_test_api) }

    context "valid and successful" do
      let!(:stripe_payment_intent_id) { "cus_#{Faker::Crypto.md5}" }
      let!(:stripe_account_id) { "acct_#{Faker::Bank.account_number(16)}" }
      let!(:use_test_api) { [true, false].sample }

      before { allow(Stripe::PaymentIntent).to receive(:retrieve) }

      it "should call the Stripe PaymentIntents API with the correct attributes" do
        expect(Stripe::PaymentIntent).to receive(:retrieve).with(stripe_payment_intent_id, stripe_account: stripe_account_id)

        retrieve
      end
    end
  end
end
