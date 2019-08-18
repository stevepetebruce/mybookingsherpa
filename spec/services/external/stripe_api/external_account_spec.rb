require "rails_helper"

RSpec.describe External::StripeApi::ExternalAccount, type: :model do
  describe "#create" do
    subject(:create) { described_class.create(account_id, external_account_token) }

    let(:account_id) { "acct_#{Faker::Crypto.md5}" }
    let(:external_account_token) { "btok_#{Faker::Crypto.md5}" }
    let(:response_body) do
      "#{file_fixture("stripe_api/successful_external_account.json").read}"
    end

    before do
      stub_request(:post, "https://api.stripe.com/v1/accounts/#{account_id}/external_accounts").
        with(body: {"external_account"=>"#{external_account_token}"}).
        to_return(status: 200, body: response_body, headers: {})
    end

    context "successful" do
      context "use_test_api is true (default)" do
        it "should use the Stripe Test API key" do
          create

          expect(Stripe.api_key).to eq ENV.fetch("STRIPE_SECRET_KEY_TEST")
        end

        it "should not raise an exception" do
          expect { create }.to_not raise_exception
        end

        it "should return a Stripe::BankAccount Object" do
          expect(create.class).to eq Stripe::BankAccount
        end
      end

      context "use_test_api is false " do
        # TODO/pending
        # it "should use the Stripe Live API key" do
        #   create

        #   expect(Stripe.api_key).to eq ENV.fetch("STRIPE_SECRET_KEY_TEST")
        # end

        # it "should not raise an exception" do
        #   expect { create }.to_not raise_exception
        # end

        # it "should return a Stripe::BankAccount Object" do
        #   expect(create.class).to eq Stripe::BankAccount
        # end
      end
    end
  end
end
