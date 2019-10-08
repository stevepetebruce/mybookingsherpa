require "rails_helper"

RSpec.describe "Webhooks::StripeApi::AccountsController", type: :request do
  describe "#create POST /webhooks/stripe_api/accounts" do
    def do_request(url: "/webhooks/stripe_api/accounts", params: {})
      post url, params: params
    end

    context "valid and successful" do
      context "when its a regular (account is not enabled for payments) update" do
        # TODO
      end

      context "when charges are enabled in Stripe" do
        let!(:organisation) { FactoryBot.create(:organisation, stripe_account_id: "acct_1FQwLOFUyBXr3CA5") }
        let(:params) do 
          JSON.parse("#{file_fixture("stripe_api/webhooks/successful_account_update_charges_enabled.json").read}")
        end

        it "should respond with a success status code" do
          do_request(params: params)

          expect(response).to be_successful
        end

        it "should update the organisation's (onboarding) stripe_account_complete" do
          do_request(params: params)

          expect(organisation.stripe_account_complete?).to eq true
        end
      end
    end
  end
end
