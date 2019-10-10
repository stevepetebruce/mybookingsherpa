require "rails_helper"

RSpec.describe "Guides::Trips::BookingsController", type: :request do
  let(:guide) { FactoryBot.create(:guide) }

  describe "#index get /guides/trips/:trip_id/bookings/" do
    include_examples "authentication"

    let!(:booking) { FactoryBot.create(:booking, guest: guest, trip: trip) }
    let!(:guest) { FactoryBot.create(:guest, name_override: guest_name) }
    let!(:guest_name) { Faker::Name.name }
    let!(:trip) { FactoryBot.create(:trip, name: trip_name, guides: [guide]) }
    let!(:trip_name) { Faker::Name.name }

    def do_request(url: "/guides/trips/#{trip.id}/bookings/", params: {})
      get url, params: params
    end

    before do
      stub_request(:post, "https://api.stripe.com/v1/account_links").
        with(body: {
          "account"=>%r{acct_\d+},
          "collect"=>"currently_due",
          "failure_url"=>"http://www.example.com/guides/welcome/stripe_account_link_failure",
          "success_url"=>"http://www.example.com/guides/trips",
          "type"=>"custom_account_verification"}).
        to_return(status: 200, body: "#{file_fixture("stripe_api/successful_account_link.json").read}", headers: {})
    end

    context "signed in" do
      before { sign_in(guide) }

      context "valid and successful" do
        it "should successfully render" do
          do_request

          expect(response).to be_successful
          expect(response.body).to include(guest.name)
        end

        context "a trip associated with one guide" do
          let!(:other_guide) { FactoryBot.create(:guide) }

          it "should be visible to the guide" do
            do_request

            expect(response.body).to include(trip_name)
          end

          it "should not be visible to another guide" do
            sign_out(guide)
            sign_in(other_guide)

            expect{ do_request }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
