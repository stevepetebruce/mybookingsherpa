require "rails_helper"

RSpec.describe "Guides::Welcome::BankAccountsController", type: :request do
  let!(:guide) { FactoryBot.create(:guide) }
  let!(:onboarding) { FactoryBot.create(:onboarding, organisation: organisation) }
  let!(:organisation) { FactoryBot.create(:organisation) }

  before do
    FactoryBot.create(:organisation_membership, guide: guide, organisation: organisation, owner: true)
  end

  describe "#new" do
    include_examples "authentication"

    def do_request(url: "/guides/welcome/bank_accounts/new", params: {})
      get url, params: params
    end

    context "signed in" do
      let(:response_body) { "#{file_fixture("stripe_api/successful_company_account_update.json").read}" }

      before do
        sign_in(guide)

        stub_request(:get, "https://api.stripe.com/v1/accounts/#{organisation.stripe_account_id_live}").
          to_return(status: 200, body: response_body, headers: {})
      end

      context "valid and successful" do
        context "a guide who hasn't set up their Stripe account fully yet" do
          it "should redirect to the guides' trips view" do
            do_request

            expect(response).to redirect_to guides_trips_path
          end
        end

        context "a guide who only has bank_account_required" do
          before do
            allow_any_instance_of(Guides::Welcome::BankAccountsController).
              to receive(:only_bank_account_required?).and_return(true)
          end

          it "should successfully render" do
            do_request

            expect(response).to be_successful
          end
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

      let!(:params) { { token_account: token_account } }
      let(:stripe_account_id) { organisation.stripe_account_id_live }
      let!(:token_account) { "btok_#{Faker::Crypto.md5}" }

      before do
        stub_request(:post, "https://api.stripe.com/v1/accounts/#{stripe_account_id}/external_accounts").
          with(body: {"external_account"=>"#{token_account}"}).
          to_return(status: 200,
                    body: "#{file_fixture("stripe_api/successful_external_account.json").read}",
                    headers: {})

        stub_request(:get, "https://api.stripe.com/v1/accounts/#{stripe_account_id}").
          to_return(status: 200,
                    body: "#{file_fixture("stripe_api/successful_company_account.json").read}",
                    headers: {})
      end

      it "should create the bank account (and track this event)" do
        do_request(params: params)

        expect(onboarding.reload.events.first["name"]).to eq("new_bank_account_created")
      end

      it "should redirect_to the guides_trips_path" do
        do_request(params: params)

        expect(response.code).to eq "302"
        expect(response).to redirect_to guides_trips_path(completed_set_up: true)
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

      context "organisation where the guide has not completed Stripe account onboarding" do
        before do
          stub_request(:get, "https://api.stripe.com/v1/accounts/#{stripe_account_id}").
          to_return(status: 200,
                    body: "#{file_fixture("stripe_api/successful_company_account_payouts_not_enabled.json").read}",
                    headers: {})
        end

        it "should not complete onboarding" do
          do_request(params: params)

          expect(onboarding.reload.complete).to eq false
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
