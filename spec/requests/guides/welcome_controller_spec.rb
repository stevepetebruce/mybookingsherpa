require "rails_helper"

RSpec.describe "Guides::WelcomeController", type: :request do
  let!(:guide) { FactoryBot.create(:guide) }
  let!(:organisation) { FactoryBot.create(:organisation) }
  let!(:organisation_membership) do
    FactoryBot.create(:organisation_membership,
                      guide: guide,
                      organisation: organisation,
                      owner: true)
  end
  let(:response_body) do
    "#{file_fixture("stripe_api/successful_account_link.json").read}"
  end

  describe "#new" do
    include_examples "authentication"

    def do_request(url: "/guides/welcome")
      get url
    end

    before do
      stub_request(:post, "https://api.stripe.com/v1/account_links").
        with(body: {
            "failure_url"=>"http://www.example.com/guides/welcome",
            "success_url"=>"http://www.example.com/guides/welcome",
            "type"=>"custom_account_verification"}).
        to_return(status: 200, body: response_body, headers: {})
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
end
