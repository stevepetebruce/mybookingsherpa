require "rails_helper"

RSpec.describe External::StripeApi::Account, type: :model do
  describe "#create_live_account" do
    subject(:create_live_account) { described_class.create_live_account(account_token) }

    let(:account_token) { "ct_#{Faker::Crypto.md5}" }
    let(:response_body) do
      "#{file_fixture("stripe_api/successful_individual_account.json").read}"
    end

    before do
      stub_request(:post, "https://api.stripe.com/v1/accounts").
        with(body: {"account_token"=>account_token, "type"=>"custom"}).
        to_return(status: 200, body: response_body, headers: {})
    end

    context "successful" do
      it "should use the Stripe live API key" do
        create_live_account

        expect(Stripe.api_key).to eq ENV.fetch("STRIPE_SECRET_KEY_LIVE")
      end

      it "should not raise an exception" do
        expect { create_live_account }.to_not raise_exception
      end

      it "should return a Stripe::Account Object" do
        expect(create_live_account.class).to eq Stripe::Account
      end
    end
  end

  describe "#create_test_account" do
    subject(:create_test_account) { described_class.create_test_account(email) }

    let(:response_body) do
      "#{file_fixture("stripe_api/successful_individual_account.json").read}"
    end

    before do
      stub_request(:post, "https://api.stripe.com/v1/accounts").
        with(body: {"country"=>"FR", "email"=>email, "type"=>"custom"}).
        to_return(status: 200, body: response_body, headers: {})
    end

    context "successful" do
      let(:email) { Faker::Internet.email }

      it "should use the Stripe test API key" do
        create_test_account

        expect(Stripe.api_key).to eq ENV.fetch("STRIPE_SECRET_KEY_TEST")
      end

      it "should not raise an exception" do
        expect { create_test_account }.to_not raise_exception
      end

      it "should return a Stripe::Account Object" do
        expect(create_test_account.class).to eq Stripe::Account
      end
    end
  end
end
