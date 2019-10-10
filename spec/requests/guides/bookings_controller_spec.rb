require "rails_helper"

RSpec.describe "Guides::BookingsController", type: :request do
  let(:guide) { FactoryBot.create(:guide) }

  describe "#show get /guides/bookings/:id" do
    include_examples "authentication"

    let!(:booking) { FactoryBot.create(:booking, guest: guest, trip: trip) }
    let!(:guest_name) { Faker::Name.name }
    let!(:guest) { FactoryBot.create(:guest, name: guest_name, name_override: guest_name) }
    let!(:trip) { FactoryBot.create(:trip, guides: [guide]) }

    def do_request(url: "/guides/bookings/#{booking.id}", params: {})
      get url, params: params
    end

    context "signed in" do
      before do
        sign_in(guide)

        stub_request(:post, "https://api.stripe.com/v1/account_links").
          with(body: {
            "account"=>%r{acct_\d+},
            "collect"=>"currently_due",
            "failure_url"=>"http://www.example.com/guides/welcome/stripe_account_link_failure",
            "success_url"=>"http://www.example.com/guides/trips",
            "type"=>"custom_account_verification"}).
          to_return(status: 200, body: "#{file_fixture("stripe_api/successful_account_link.json").read}", headers: {})
      end

      context "valid and successful" do
        it "should successfully render" do
          do_request

          expect(response).to be_successful
        end

        context "a guest associated with one guide" do
          let!(:other_guide) { FactoryBot.create(:guide) }

          it "should be visible to the guide" do
            do_request

            expect(response.body).to include(guest_name)
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
  end
end
