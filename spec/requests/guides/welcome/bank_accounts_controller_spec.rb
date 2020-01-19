require "rails_helper"

RSpec.describe "Guides::Welcome::BankAccountsController", type: :request do
  let!(:guide) { FactoryBot.create(:guide) }
  let!(:organisation) { FactoryBot.create(:organisation) }

  before do
    FactoryBot.create(:organisation_membership, guide: guide, organisation: organisation, owner: true)
    FactoryBot.create(:onboarding, organisation: organisation)
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

        context "a guide who has set up their Stripe account" do
          before { organisation.onboarding.update(stripe_account_complete: true) }

          it "should successfully render" do
            pending 'Jan 2020 rush job - II'
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

      let(:onboarding) { organisation.onboarding }
      let!(:organisation) { FactoryBot.create(:organisation) }
      let!(:params) { { token_account: token_account } }
      let(:response_body) do
        "#{file_fixture("stripe_api/successful_external_account.json").read}"
      end
      let(:stripe_account_id) { organisation.stripe_account_id_live }
      let!(:token_account) { "btok_#{Faker::Crypto.md5}" }

      before do
        stub_request(:post, "https://api.stripe.com/v1/accounts/#{stripe_account_id}/external_accounts").
          with(body: {"external_account"=>"#{token_account}"}).
          to_return(status: 200, body: response_body, headers: {})
      end

      it "should create the bank account (and track this event)" do
        pending 'Jan 2020 rush job - II'
        do_request(params: params)

        expect(onboarding.events.first["name"]).to eq("new_bank_account_created")
      end

      it "should redirect_to the guides_trips_path" do
        pending 'Jan 2020 rush job - II'
        do_request(params: params)

        expect(response.code).to eq "302"
        expect(response).to redirect_to guides_trips_path(completed_set_up: true)
      end

      context "organisation with a solo founder" do
        before { organisation.onboarding.track_event("new_solo_account_chosen") }

        it "should complete onboarding" do
          pending 'Jan 2020 rush job - II'
          do_request(params: params)

          expect(onboarding.reload.complete).to eq true
          expect(onboarding.find_event("trial_ended")).to_not be_nil
        end

        it "should call the DestroyTrialGuestsJob job" do
          pending 'Jan 2020 rush job - II'
          expect(Onboardings::DestroyTrialGuestsJob).
            to receive(:perform_later).
            with(organisation)

            do_request(params: params)
        end
      end

      context "organisation that's a company with directors/owners" do
        it "should complete onboarding" do
          pending 'Jan 2020 rush job - II'
          do_request(params: params)

          expect(onboarding.complete).to eq true
          expect(onboarding.find_event("trial_ended")).to_not be_nil
        end

        it "should call the DestroyTrialGuestsJob job" do
          pending 'Jan 2020 rush job - II'
          expect(Onboardings::DestroyTrialGuestsJob).
            to receive(:perform_later).
            with(organisation)

          do_request(params: params)
        end
      end
    end
  end
end
