require "rails_helper"

RSpec.describe "Guides::BookingsController", type: :request do
  let(:guide) { FactoryBot.create(:guide) }
  let(:organisation) { FactoryBot.create(:organisation) }

  before do
    FactoryBot.create(:organisation_membership, organisation: organisation, guide: guide, owner: true)
  end

  describe "#show get /guides/bookings/:id" do
    include_examples "authentication"

    let!(:booking) { FactoryBot.create(:booking, guest: guest, trip: trip) }
    let!(:guest_name) { Faker::Name.name }
    let!(:guest) { FactoryBot.create(:guest, name: guest_name, name_override: guest_name) }
    let!(:trip) { FactoryBot.create(:trip, guides: [guide]) }

    def do_request(url: "/guides/bookings/#{booking.id}", params: {})
      # TODO: remove and fix this:
      run_hack_to_fix_habtm_trip_organisation_creation_bug
      get url, params: params
    end

    context "signed in" do
      before do
        sign_in(guide)

        stub_request(:post, "https://api.stripe.com/v1/account_links").
          with(body: {
            "account"=>%r{acct_\d+},
            "collect"=>"eventually_due",
            "failure_url"=>"http://www.example.com/guides/welcome/stripe_account_link_failure",
            "success_url"=>"http://www.example.com/guides/welcome/bank_accounts/new",
            "type"=>"account_onboarding"}).
          to_return(status: 200, body: "#{file_fixture("stripe_api/successful_account_link.json").read}", headers: {})
      end

      context "valid and successful" do
        it "should successfully render" do
          do_request

          expect(response).to be_successful
        end

        context "a guest associated with one guide" do
          let(:other_guide) { FactoryBot.create(:guide) }
          let(:other_organisation) { FactoryBot.create(:organisation) }

          before do
            FactoryBot.create(:organisation_membership, organisation: other_organisation, guide: other_guide, owner: true)
          end

          it "should be visible to the guide" do
            do_request

            expect(response.body).to include(CGI.escapeHTML(guest_name))
          end

          it "should not be visible to another guide" do
            sign_out(guide)
            sign_in(other_guide)

            expect{ do_request }.to raise_error(ActiveRecord::RecordNotFound)
            # And redirect_to?
          end
        end
      end
    end

    def run_hack_to_fix_habtm_trip_organisation_creation_bug
      Organisation.all.each { |org| FactoryBot.create(:onboarding, organisation: org) unless org.onboarding }
    end
  end
end
