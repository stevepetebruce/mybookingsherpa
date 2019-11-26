require "rails_helper"

RSpec.describe "Webhooks::StripeApi::AccountsController", type: :request do
  describe "#create POST /webhooks/stripe_api/accounts" do
    def do_request(url: "/webhooks/stripe_api/accounts", params: {}, headers: {})
      post url, params: params, headers: headers, as: :json
    end

    context "valid and successful" do
      let(:event) do
        JSON.parse("#{file_fixture("/stripe_api/webhooks/successful_account_update_charges_not_enabled.json").read}")
      end
      let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
      let!(:organisation) { FactoryBot.create(:organisation, stripe_account_id_live: "acct_1FbAREIy86KmMnUD") }
      let(:params) { event }
      let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_CONNECT_ACCOUNTS"] }

      context "when its a regular (account is not enabled for payments) update" do
        it "should NOT update the organisation's (onboarding) stripe_account_complete to true" do
          do_request(params: params, headers: headers)

          expect(organisation.reload.stripe_account_complete?).to eq false
        end
      end

      context "when charges are enabled in Stripe" do
        let(:event) do
          JSON.parse("#{file_fixture("/stripe_api/webhooks/successful_account_update_charges_enabled.json").read}")
        end
        let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
        let!(:organisation) { FactoryBot.create(:organisation, stripe_account_id_live: "acct_1FQwLOFUyBXr3CA5") }
        let(:params) { event }
        let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_CONNECT_ACCOUNTS"] }

        it "should respond with a success status code" do
          do_request(params: params, headers: headers)

          expect(response).to be_successful
        end

        it "should update the organisation's (onboarding) stripe_account_complete" do
          do_request(params: params, headers: headers)

          expect(organisation.stripe_account_complete?).to eq true
        end
      end
    end
  end
end
