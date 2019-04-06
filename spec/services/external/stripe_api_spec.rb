require "rails_helper"

RSpec.describe External::StripeApi, type: :model do
  describe "#charge" do
    subject(:charge) { described_class.new(attributes).charge }

    let(:attributes) do
      {
        amount: rand(5000...10_000),
        application_fee_amount: rand(100...10_000),
        currency: %w[eur usd gbp].sample,
        description: Faker::Lorem.sentence,
        transfer_data: transfer_data,
        token: "tok_#{Faker::Crypto.md5}"
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
      it "should not raise an exception" do
        expect { charge }.to_not raise_exception
      end

      it "should return a Stripe::Charge Object" do
        expect(charge.class).to eq Stripe::Charge
      end
    end
  end
end
