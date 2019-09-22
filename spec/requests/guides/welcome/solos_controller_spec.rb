require "rails_helper"

RSpec.describe "Guides::Welcome::SolosController", type: :request do
  let!(:guide) { FactoryBot.create(:guide) }
  let(:onboarding) { organisation.onboarding }
  let!(:organisation) { FactoryBot.create(:organisation) }
  let!(:organisation_membership) do
    FactoryBot.create(:organisation_membership,
                      guide: guide,
                      organisation: organisation,
                      owner: true)
  end

  describe "#new" do
    include_examples "authentication"

    def do_request(url: "/guides/welcome/solos/new", params: {})
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

  describe "#create POST /guides/welcome/solos" do
    include_examples "authentication"

    def do_request(url: "/guides/welcome/solos", params: {})
      post url, params: params
    end

    context "signed in" do
      before do
        stub_request(:post, "https://api.stripe.com/v1/accounts").
          with(body: {
            "account_token"=>token_account,
            "requested_capabilities"=>["card_payments", "transfers"],
            "type"=>"custom"}).
          to_return(status: 200, body: response_body, headers: {})

        sign_in(guide)
      end

      context "valid and successful" do
        let!(:params)  { { token_account: token_account } }
        let(:response_body) do
          "#{file_fixture("stripe_api/successful_individual_account.json").read}"
        end
        let!(:token_account) { "ct_#{Faker::Crypto.md5}" }

        it "should update the organisation's stripe_account_id" do
          do_request(params: params)

          expect(organisation.reload.stripe_account_id).not_to be_nil
        end

        it "should redirect_to the new_guides_welcome_bank_account page (to now create the bank account)" do
          do_request(params: params)

          expect(response.code).to eq "302"
          expect(response).to redirect_to new_guides_welcome_bank_account_url
        end

        it "should track the onboarding event" do
          do_request(params: params)

          expect(onboarding.events.first["name"]).to eq("new_solo_account_chosen")
        end

        it "should track the onboarding event" do
          do_request(params: params)

          expect(onboarding.events.second["name"]).to eq("new_stripe_account_created")
        end
      end

      context "invalid and unsuccessful" do
        let(:params)  { { token_account: token_account } }
        let(:response_body) do
          "#{file_fixture("stripe_api/successful_individual_account.json").read}"
        end
        let(:stripe_account_id) { "acct_1F6EFsL2bc7IXTSh" } # from: successful_individual_account.json
        let!(:token_account) { "ct_#{Faker::Crypto.md5}" }

        context "problem updating organisation" do
          before do
            allow_any_instance_of(Organisation).to receive(:update).
              with(stripe_account_id: stripe_account_id).
              and_return(false)
          end
          it "should render the new_guides_welcome_solo page" do
            do_request(params: params)

            expect(response.code).to eq "200"
          end

          it "should track the onboarding event" do
            do_request(params: params)

            expect(onboarding.events.second["name"]).to eq("failed_new_stripe_account_creation")
          end
        end

        context "Stripe API throws an exception" do
          before do
            allow(External::StripeApi::Account).
              to receive(:create_live_account).
              with(token_account).
              and_raise(Stripe::InvalidRequestError.new(exception_message, exception_param, http_status: exception_http_status))
          end

          let(:exception_message) { "Address for business must match account country" }
          let(:exception_param) { "individual[address][country]" }
          let(:exception_http_status) { 400 }

          it "should render the new_guides_welcome_solo page" do
            do_request(params: params)

            expect(response.code).to eq "200"
            expect(response.body).to include(exception_message)
          end

          it "should track the onboarding event" do
            do_request(params: params)

            expect(onboarding.events.second["name"]).to eq("failed_new_stripe_account_creation")
            expect(onboarding.events.second["additional_info"]).to eq("Address for business must match account country")
          end
        end
      end
    end
  end
end
