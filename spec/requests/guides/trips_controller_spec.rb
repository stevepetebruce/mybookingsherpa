require "rails_helper"

RSpec.describe "Guides::TripsController", type: :request do
  let!(:guide) { FactoryBot.create(:guide) }
  let!(:organisation) { FactoryBot.create(:organisation) }
  let!(:organisation_membership) do
    FactoryBot.create(:organisation_membership,
                      guide: guide,
                      organisation: organisation)
  end

  describe "#index get /guides/trips" do
    include_examples "authentication"

    def do_request(url: "/guides/trips/", params: {})
      get url, params: params
    end

    context "signed in" do
      before { sign_in(guide) }

      context "valid and successful" do
        it "should successfully render" do
          do_request

          expect(response).to be_successful
        end

        context "a trip associated with one guide" do
          let!(:other_guide) { FactoryBot.create(:guide) }
          let!(:trip) { FactoryBot.create(:trip, guides: [guide]) }

          it "should be visible to the guide" do
            do_request

            expect(response.body).to include(trip.name)
          end

          it "should not be visible to another guide" do
            sign_out(guide)
            sign_in(other_guide)

            do_request

            expect(response.body).to_not include(trip.name)
          end
        end

        context "past vs future trips" do
          context "a trip with an end_date in the past" do
            let!(:trip) { FactoryBot.create(:trip, guides: [guide], start_date: 2.weeks.ago, end_date: 1.week.ago) }

            context "without any other params" do
              it "should not be visible" do
                do_request

                expect(response.body).to_not include(trip.name)
              end
            end

            context "with past_trips=true" do
              let(:params) { { past_trips: true } }

              it "should be visible" do
                do_request(params: params)

                expect(response.body).to include(trip.name)
              end
            end
          end

          context "a trip with an end_date in the future" do
            let!(:trip) { FactoryBot.create(:trip, guides: [guide], start_date: 2.weeks.from_now, end_date: 3.weeks.from_now) }

            context "without any other params" do
              it "should be visible" do
                do_request

                expect(response.body).to include(trip.name)
              end
            end

            context "with past_trips=true" do
              let(:params) { { past_trips: true } }

              it "should not be visible" do
                do_request(params: params)

                expect(response.body).to_not include(trip.name)
              end
            end
          end
        end
      end
    end
  end
end
