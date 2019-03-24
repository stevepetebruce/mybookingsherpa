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
      before { sign_in(guide) }

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
