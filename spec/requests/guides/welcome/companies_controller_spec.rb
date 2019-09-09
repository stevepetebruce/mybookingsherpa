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

        it "should track the onboarding event" do
          do_request

          expect(onboarding.events.first["name"]).to eq("new_company_account_chosen")
        end
      end
    end
  end
end
