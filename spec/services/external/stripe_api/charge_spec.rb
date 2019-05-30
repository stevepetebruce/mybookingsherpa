require "rails_helper"

RSpec.describe External::StripeApi::Charge, type: :model do
  describe "#create" do
    subject(:create) { described_class.create(attributes) }

    let(:attributes) do
      {
        amount: rand(5000...10_000),
        application_fee_amount: rand(100...10_000),
        currency: %w[eur usd gbp].sample,
        customer: "cus_#{Faker::Crypto.md5}",
        description: Faker::Lorem.sentence,
        transfer_data: transfer_data,
        use_test_api: use_test_api
      }
    end

    let(:response_body) do
      "#{file_fixture("stripe_api/successful_charge.json").read}"
    end

    let(:transfer_data) do
      {
        destination: "acct_#{Faker::Bank.account_number(16)}"
      }
    end

    before do
      stub_request(:post, "https://api.stripe.com/v1/charges")
        .to_return(status: 200,
                   body: response_body,
                   headers: {})
    end

    context "successful" do
      context "use_test_api is true" do
        let(:use_test_api) { true }

        it "should use the Stripe Test API key" do
          create

          expect(Stripe.api_key).to eq ENV.fetch("STRIPE_SECRET_KEY_TEST")
        end

        it "should not raise an exception" do
          expect { create }.to_not raise_exception
        end

        it "should return a Stripe::Charge Object" do
          expect(create.class).to eq Stripe::Charge
        end
      end

      context "use_test_api is false" do
        let(:use_test_api) { false }

        it "should use the Stripe Live API key" do
          create

          expect(Stripe.api_key).to eq ENV.fetch("STRIPE_SECRET_KEY_LIVE")
        end

        it "should not raise an exception" do
          expect { create }.to_not raise_exception
        end

        it "should return a Stripe::Charge Object" do
          expect(create.class).to eq Stripe::Charge
        end
      end
    end
  end
end
