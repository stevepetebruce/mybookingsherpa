require "rails_helper"

RSpec.describe "Guides::Welcome::CompaniesController", type: :request do
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

    def do_request(url: "/guides/welcome/companies/new", params: {})
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

  describe "#create POST /guides/welcome/companies" do
    include_examples "authentication"

    def do_request(url: "/guides/welcome/companies", params: {})
      post url, params: params
    end

    before do
      stub_request(:post, "https://api.stripe.com/v1/accounts").
        with(body: {
          "account_token"=>token_account,
          "requested_capabilities"=>["card_payments", "transfers"],
          "type"=>"custom"}).
        to_return(status: 200, body: response_body, headers: {})
    end

    let(:response_body) do
      "#{file_fixture("stripe_api/successful_company_account.json").read}"
    end
    let!(:token_account) { "ct_#{Faker::Crypto.md5}" }

    context "signed in" do
      before { sign_in(guide) }

      let!(:params) { { token_account: token_account } }

      context "valid and successful" do
        it "should assign the organisation's stripe_account_id" do
          do_request(params: params)

          expect(organisation.reload.stripe_account_id).to_not be_nil
        end

        it "should redirect_to the new_guides_welcome_director_path" do
          do_request(params: params)

          expect(response.code).to eq "302"
          expect(response).to redirect_to new_guides_welcome_director_path
        end

        it "should track the onboarding event" do
          do_request(params: params)

          expect(onboarding.events.first["name"]).to eq("new_company_account_chosen")
        end
      end

      context "unsuccessful" do
        before do
          allow_any_instance_of(Organisation).to receive(:update).
            with(stripe_account_id: stripe_account_id).
            and_return(false)
        end

        let(:stripe_account_id) { "acct_1DLYH2ESypPNvvdY" } # from: successful_company_account.json

        it "should render the new_guides_welcome_director page" do
          do_request(params: params)

          expect(response.code).to eq "200"
        end
      end
    end
  end
end
