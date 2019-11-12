require "rails_helper"

RSpec.describe External::StripeApi::PaymentIntent, type: :model do
  describe "#create" do
    subject(:create) { described_class.create(attributes, use_test_api: use_test_api) }

    context "valid and successful" do
      let(:attributes) do
        {
          amount: Faker::Number.between(1_000, 10_000),
          application_fee_amount: [0, 200, 400].sample,
          currency: %w[eur, gbp, usd].sample,
          customer: "cus_#{Faker::Crypto.md5}",
          setup_future_usage: %w[off_session on_session].sample,
          statement_descriptor: Faker::Lorem.sentence.truncate(22, separator: " "),
          transfer_data:
            {
              destination: "acct_#{Faker::Bank.account_number(16)}"
            }
        }
      end
      let!(:use_test_api) { [true, false].sample }

      before do
        stub_request(:post, "https://api.stripe.com/v1/payment_intents").
          with(body: attributes).
          to_return(status: 200,
                    body: "#{file_fixture("stripe_api/successful_payment_intent.json").read}",
                    headers: {})
      end

      it "should call the Stripe PaymentIntents API with the correct attributes" do
        expect(Stripe::PaymentIntent).to receive(:create).with(attributes)

        create
      end

      context "a statement_descriptor with non-alphanumeric characters in" do
        let!(:amount) { Faker::Number.between(1_000, 10_000) }
        let!(:application_fee_amount) { [0, 200, 400].sample }
        let!(:currency) { %w[eur, gbp, usd].sample }
        let!(:customer) { "cus_#{Faker::Crypto.md5}" }
        let!(:destination) {  "acct_#{Faker::Bank.account_number(16)}" }

        let(:attributes) do
          {
            amount: amount,
            application_fee_amount: application_fee_amount,
            currency: currency,
            customer: customer,
            setup_future_usage: "off_session",
            statement_descriptor: "Ivy's Big Adventure",
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
            statement_descriptor: "Ivy_s Big Adventure",
            transfer_data:
              {
                destination: destination
              }
          }
        end

        it "should sanitize the attributes and make a successful call to the Stripe API" do
          expect(Stripe::PaymentIntent).to receive(:create).with(sanitized_attributes)

          create
        end
      end

      it "should return a Stripe PaymentIntent object" do
        # TODO: need to get a payment intent response and return it (may be using the wrong fixture ^)
      end
    end
  end
end
