require "rails_helper"

RSpec.describe External::StripeApi::Account, type: :model do
  describe "#create_live_account_from_token" do
    subject(:create_live_account_from_token) { described_class.create_live_account_from_token(account_token) }

    let(:account_token) { "ct_#{Faker::Crypto.md5}" }
    let(:response_body) do
      "#{file_fixture("stripe_api/successful_individual_account.json").read}"
    end

    before do
      stub_request(:post, "https://api.stripe.com/v1/accounts").
        with(body: {
          "account_token"=>account_token,
          "requested_capabilities"=>["card_payments", "transfers"],
          "type"=>"custom"}).
        to_return(status: 200, body: response_body, headers: {})
    end

    context "successful" do
      it "should use the Stripe live API key" do
        create_live_account_from_token

        expect(Stripe.api_key).to eq ENV.fetch("STRIPE_SECRET_KEY_LIVE")
      end

      it "should not raise an exception" do
        expect { create_live_account_from_token }.to_not raise_exception
      end

      it "should return a Stripe::Account Object" do
        expect(create_live_account_from_token.class).to eq Stripe::Account
      end
    end
  end

  describe "#create_test_account" do
    subject(:create_test_account) { described_class.create_test_account(country_code, email) }

    let(:response_body) do
      "#{file_fixture("stripe_api/successful_individual_account.json").read}"
    end

    before do
      stub_request(:post, "https://api.stripe.com/v1/accounts").
        with(body: {
          "country"=>country_code.upcase,
          "email"=>email,
          "requested_capabilities"=>["card_payments", "transfers"],
          "type"=>"custom"}).
        to_return(status: 200, body: response_body, headers: {})

      stub_request(:post, "https://api.stripe.com/v1/accounts").
         with(body: {
          "country"=>country_code,
          "email"=>email,
          "requested_capabilities"=>["card_payments", "transfers"],
          "type"=>"custom"}).
         to_return(status: 200, body: response_body, headers: {})
    end

    context "successful" do
      let!(:country_code) { Faker::Address.country_code }
      let!(:email) { Faker::Internet.email }

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

  describe "#update" do
    subject(:update) { described_class.new(account_token: account_token).update(stripe_account_id) }

    let(:account_token) { "ct_#{Faker::Crypto.md5}" }
    let(:response_body) { "#{file_fixture("stripe_api/successful_company_account_update.json").read}" }
    let(:stripe_account_id) { "acct_#{Faker::Bank.account_number(digits: 16)}" }

    before do
      stub_request(:post, "https://api.stripe.com/v1/accounts/#{stripe_account_id}").
        to_return(status: 200, body: response_body, headers: {})
    end

    it "should call Stripe::Account.update" do
      expect(Stripe::Account).to receive(:update).with(stripe_account_id, account_token: account_token)

      update
    end
  end

  describe "#retrieve" do
    subject(:retrieve) { described_class.retrieve(stripe_account_id) }

    let(:response_body) { "#{file_fixture("stripe_api/successful_company_account_update.json").read}" }
    let!(:stripe_account_id) { "acct_#{Faker::Bank.account_number(digits: 16)}" }

    before do
      stub_request(:post, "https://api.stripe.com/v1/accounts/acct_1DLYH2ESypPNvvdY").
        to_return(status: 200, body: response_body, headers: {})
    end

    it "should call Stripe::Account.retrieve" do
      expect(Stripe::Account).to receive(:retrieve).with(stripe_account_id)

      retrieve
    end
  end
end
