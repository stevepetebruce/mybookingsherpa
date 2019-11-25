require "rails_helper"

RSpec.describe "Guides::Welcome::StripeAccountLinkFailureController", type: :request do
  describe "#new" do
    let!(:guide) { FactoryBot.create(:guide) }
    let!(:organisation) { FactoryBot.create(:organisation) }
    let!(:organisation_membership) do
      FactoryBot.create(:organisation_membership,
                        guide: guide,
                        organisation: organisation,
                        owner: true)
    end

    def do_request(url: "/guides/welcome/stripe_account_link_failure", params: {})
      get url, params: params
    end

    before do
      stub_request(:post, "https://api.stripe.com/v1/account_links").
        with(body: {
          "account"=>%r{acct_\d+},
          "collect"=>"currently_due",
          "failure_url"=>"http://www.example.com/guides/welcome/stripe_account_link_failure",
          "success_url"=>"http://www.example.com/guides/welcome/bank_accounts/new",
          "type"=>"custom_account_verification"}).
        to_return(status: 200, body: "#{file_fixture("stripe_api/successful_account_link.json").read}", headers: {})
    end

    include_examples "authentication"

    context "signed in" do
      before { sign_in(guide) }

      context "valid and successful" do
        it "should redirect to a new Stripe account link" do
          do_request

          expect(response.location).to match('https://connect.stripe.com/setup/')
        end
      end
    end
  end
end
