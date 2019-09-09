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

      context "organisation with a solo founder" do
        before { organisation.onboarding.track_event("new_solo_account_chosen") }

        it "should complete onboarding" do
          do_request(params: params)

          expect(onboarding.reload.complete).to eq true
          expect(onboarding.find_event("trial_ended")).to_not be_nil
        end

        it "should call the DestroyTrialGuestsJob job" do
          expect(Onboardings::DestroyTrialGuestsJob).
            to receive(:perform_later).
            with(organisation)

            do_request(params: params)
        end
      end

      context "organisation that's a company with directors/owners" do
        before { organisation.onboarding.track_event("new_company_account_chosen") }

        it "should not complete onboarding" do
          do_request(params: params)

          expect(onboarding.complete).to eq false
          expect(onboarding.find_event("trial_ended")).to be_nil
        end

        it "should not call the DestroyTrialGuestsJob job" do
          expect(Onboardings::DestroyTrialGuestsJob).
            to_not receive(:perform_later).
            with(organisation)

          do_request(params: params)
        end
      end
    end
  end
end
