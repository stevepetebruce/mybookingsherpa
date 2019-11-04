require "rails_helper"

RSpec.describe "Guides::TripsController", type: :request do
  let!(:guide) { FactoryBot.create(:guide) }
  let!(:organisation) { FactoryBot.create(:organisation, :with_stripe_account_id) }
  let!(:organisation_membership) do
    FactoryBot.create(:organisation_membership,
                      guide: guide,
                      organisation: organisation,
                      owner: true)
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

  describe "#create POST /guides/trips/" do
    include_examples "authentication"

    def do_request(url: "/guides/trips", params: {})
      post url, params: params
    end

    context "signed in" do
      before { sign_in(guide) }

      context "valid and successful" do
        let!(:params) do
          {
            trip:
            {
              deposit_percentage: rand(5...50),
              full_cost: rand(10_000...50_000),
              full_payment_window_weeks: rand(1...10),
              name: Faker::Name.name,
              start_date: 4.weeks.from_now,
              end_date: 5.weeks.from_now,
              minimum_number_of_guests: rand(1...5),
              maximum_number_of_guests: rand(5...10)
            }
          }
        end

        it "creates a new trip" do
          expect { do_request(params: params) }.
            to change { guide.trips.reload.count }.
            from(0).to(1)
        end
      end

      context "unsuccesful" do
        context "guide fails to add a full_cost" do
          let!(:params) do
            {
              trip:
              {
                full_cost: nil,
                name: Faker::Name.name,
                start_date: 4.weeks.from_now,
                end_date: 5.weeks.from_now,
                minimum_number_of_guests: rand(1...5),
                maximum_number_of_guests: rand(5...10)
              }
            }
          end

          it 'should redirect back with error message' do
            do_request(params: params)

            expect(response.code).to eq "200"
            # TODO: Pending... need to surface the error message in the view
            # expect(response.body).to include("Please enter a valid email")
          end
        end
      end
    end
  end

  describe "#destroy DELETE /guides/trips/:id" do
    include_examples "authentication"

    def do_request(url: "/guides/trips/#{trip.id}", params: {})
      delete url, params: params
    end

    let!(:trip) { FactoryBot.create(:trip, guides: [guide]) }

    context "signed in" do
      before { sign_in(guide) }

      context "valid and successful" do
        context "a trip without any bookings" do
          it "should delete the trip" do
            expect { do_request }.to change{ guide.trips.count }.from(1).to(0)
          end

          it "should redirect_to guides_trips_path" do
            do_request

            expect(response).to redirect_to guides_trips_path
          end
        end

        context "a trip with bookings" do
          before { FactoryBot.create(:booking, trip: trip) }

          it "should not delete the trip" do
            expect { do_request }.to_not change{ guide.trips.count }
          end

          it "should redirect_to guides_trips_path with correct error message" do
            do_request

            expect(response).to redirect_to guides_trips_path
            # TODO: doesn't look like we're surfacing error messages in the views
            # expect(response.body).to include("can not delete trip with bookings")
          end
        end
      end

      context "invalid and unsuccesful" do
        before { allow_any_instance_of(Trip).to receive(:destroy).and_return(false) }

        it "should redirect_to guides_trips_path with correct error message" do
          do_request

          expect(response).to redirect_to guides_trips_path
          # TODO: doesn't look like we're surfacing error messages in the views
          # expect(response.body).to include("problem deleting trip")
        end
      end
    end
  end

  describe "#edit GET /guides/trips/:id/edit" do
    include_examples "authentication"

    let!(:trip) { FactoryBot.create(:trip, guides: [guide]) }

    def do_request(url: "/guides/trips/#{trip.id}/edit", params: {})
      get url, params: params
    end

    context "signed in" do
      before { sign_in(guide) }

      context "valid and successful" do
        it "should render successfully" do
          do_request

          expect(response).to be_successful
          expect(response.body).to include(Currency.human_readable(trip.full_cost))
        end
      end
    end
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
          let(:other_organisation) { FactoryBot.create(:organisation) }
          let!(:trip) { FactoryBot.create(:trip, guides: [guide]) }

          before do
            FactoryBot.create(:organisation_membership,
                              guide: other_guide,
                              organisation: other_organisation,
                              owner: true)
          end

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

              it "should have a link to past trips" do
                do_request

                expect(response.body).to include('<a class="btn btn-primary" href="/guides/trips?past_trips=true">My Past Trips</a>')
              end
            end

            context "with past_trips=true" do
              let(:params) { { past_trips: true } }

              it "should be visible" do
                do_request(params: params)

                expect(response.body).to include(trip.name)
              end

              it "should have a link to my (future) trips" do
                do_request(params: params)

                expect(response.body).to include('<a class="btn btn-primary" href="/guides/trips">My Trips</a>')
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

        context "a guide without any trips" do
          it "should show the welcome screen" do
            do_request

            expect(response.body).to include("Let's create your first trip")
          end
        end
      end
    end
  end

  describe "#new" do
    include_examples "authentication"

    def do_request(url: "/guides/trips/new", params: {})
      get url, params: params
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

  describe "#update PATCH /guides/trips/:id" do
    include_examples "authentication"

    let(:trip) { FactoryBot.create(:trip, guides: [guide]) }

    def do_request(url: "/guides/trips/#{trip.id}", params: {})
      patch url, params: params
    end

    context "signed in" do
      before { sign_in(guide) }

      context "valid and successful" do
        let!(:full_cost) { Faker::Number.between(500, 1000) }
        let!(:params) do
          {
            trip: {
              name: Faker::Name.name,
              full_cost: full_cost,
            }
          }
        end

        it "should update the trip" do
          do_request(params: params)

          expect(response.status).to eq(302)

          expect(trip.reload.name).to eq params[:trip][:name]
          expect(trip.full_cost).to eq (full_cost * 100) # converted to cents
        end
      end

      context "invalid and unsuccessful" do
        let!(:params) { { trip: { name: nil } } }

        it "should not update the guest" do
          do_request(params: params)

          expect(response.status).to eq(200)

          expect(trip.reload.name).to_not eq(params[:trip][:name])
        end
      end
    end
  end
end
