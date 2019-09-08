require "rails_helper"

RSpec.describe "Guides::Welcome::BankAccountsController", type: :request do
  let!(:guide) { FactoryBot.create(:guide) }
  let!(:organisation) { FactoryBot.create(:organisation) }
  let!(:organisation_membership) do
    FactoryBot.create(:organisation_membership,
                      guide: guide,
                      organisation: organisation,
                      owner: true)
  end

  describe "#new" do
    include_examples "authentication"

    def do_request(url: "/guides/welcome/bank_accounts/new", params: {})
      get url, params: params
    end

    context "signed in" do
      before { sign_in(guide) }

      context "valid and successful" do
        it "should successfully render" do
          do_request

          expect(response).to be_successful
        end
      end
    end
  end

  describe "#create POST /guides/welcome/bank_accounts" do
    include_examples "authentication"

    def do_request(url: "/guides/welcome/bank_accounts", params: {})
      post url, params: params
    end

    context "signed in" do
      before { sign_in(guide) }

      let(:onboarding) { organisation.onboarding }
      let!(:organisation) { FactoryBot.create(:organisation, :with_stripe_account_id) }
      let!(:params) { { token_account: token_account } }
      let(:response_body) do
        "#{file_fixture("stripe_api/successful_external_account.json").read}"
      end
      let(:stripe_account_id) { organisation.stripe_account_id }
      let!(:token_account) { "btok_#{Faker::Crypto.md5}" }

      before do
        stub_request(:post, "https://api.stripe.com/v1/accounts/#{stripe_account_id}/external_accounts").
          with(body: {"external_account"=>"#{token_account}"}).
          to_return(status: 200, body: response_body, headers: {})
      end

      it "should create the bank account (and track this event)" do
        do_request(params: params)

        expect(onboarding.events.first["name"]).to eq("new_bank_account_created")
      end

      it "should redirect_to the guides_trips_path" do
        do_request(params: params)

        expect(response.code).to eq "302"
        expect(response).to redirect_to guides_trips_url
      end

      it "should complete onboarding (TODO: for solos this means completion but probaby not for companies" do
        do_request(params: params)

        expect(onboarding.complete).to eq true
      end
    end
  end
end
