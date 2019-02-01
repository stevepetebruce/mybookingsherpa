require "rails_helper"

RSpec.describe "Guides::TripsController", type: :request do
  let!(:guide) { FactoryBot.create(:guide) }
  let!(:organisation) { FactoryBot.create(:organisation) }
  let!(:organisation_membership) do
    FactoryBot.create(:organisation_membership,
                      guide: guide,
                      organisation: organisation)
  end

  # TODO: ** implement created_by and updated_by and test them here

  describe "#create POST /guides/trips" do
    include_examples "authentication"    

    def do_request(url: "/guides/trips", params: {})
      post url, params: params
    end

    context "signed in" do
      before { sign_in(guide) }

      context "valid and successful" do
        let(:trip) { Array(guide.trips).last }
        let!(:params) do 
          {
            trip: {
              name: Faker::Name.name,
              full_cost: 500,
              maximum_number_of_guests: 12
            } 
          }
        end

        it "should create a new trip" do
          do_request(params: params)

          expect(response.code).to eq "302"
          expect(response).to redirect_to(guides_trip_path(trip))

          expect(guide.trips.include?(Trip.last))

          expect(trip.name).to eq params[:trip][:name]
          expect(trip.full_cost).to eq params[:trip][:full_cost]
          expect(trip.maximum_number_of_guests).to eq params[:trip][:maximum_number_of_guests]

          # TODO: ** expect(trip.created_by).to eq guide
          # TODO: ** expect(trip.updated_by).to eq guide
        end
      end

      context "invalid and unsuccessful" do
        let!(:params) { { trip: { name: nil } } }

        it "should not create a new trip" do
          expect { do_request(params: params) }.to_not change { Trip.count }
          expect(response.code).to eq "200"
        end
      end
    end
  end

  describe "#destroy DELETE /guides/trips" do
    # include_examples "authentication"
    # Soft delete?
    # let!(:trip) { create(:trip) }

    # def do_request(url: "/guides/trips/#{trip.id}", params: {})
    #   delete url, params: params
    # end

    # context "signed in" do
    #   before do
    #     sign_in user
    #     stub_vault_submission_post
    #   end

    #   context "trip sucessfully deleted" do
    #     it "should be deleted" do
    #       expect { do_request }.to change { trip.count }.by(-1)

    #       expect(response.code).to eq "302"
    #     end
    #   end
    # end
    # TODO: ** expect(trip.updated_by).to eq user
  end

  describe "#edit GET /guides/trips/:id/edit" do
    include_examples "authentication"

    let!(:trip) do 
      guide.trips.create(name: Faker::Name.name,
                         full_cost: 500,
                         maximum_number_of_guests: 12,
                         organisation: organisation)
    end

    def do_request(url: "/guides/trips/#{trip.id}/edit", params: {})
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

    context "guide who is not associated with this trip" do
      # TODO: Only a trip owner / guide who belongs to this trip's org can edit a trip
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
      end
    end
  end

  describe "#new GET /guides/trips/new" do
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

    context "guide who is not associated with this trip" do
      # TODO: Only a trip owner / guide who belongs to this trip's org can edit a trip
    end
  end

  describe "#update PATCH /guides/trips/:id" do
    include_examples "authentication"

    let!(:trip) do 
      guide.trips.create(name: Faker::Name.name,
                         full_cost: 500,
                         maximum_number_of_guests: 12,
                         organisation: organisation)
    end

    def do_request(url: "/guides/trips/#{trip.id}", params: {})
      patch url, params: params
    end


    context "signed in" do
      before { sign_in(guide) }

      context "valid and successful" do
        let(:params) { { trip: { name: Faker::Name.name } } }

        it "should update the trip name" do
          expect { do_request(params: params) }.to change { trip.reload.name }.to(params[:trip][:name])
        end

        # TODO: ** it "should update the trip updated_by" do
        #   expect { do_request(params: params) }.to change { trip.reload.updated_by }.to(user)
        # end
      end

      context "invalid and unsuccessful" do
        context "invalid params" do
          let!(:params) { { trip: { name: nil } } }

          it "should not update the trip" do
            expect { do_request(params: params) }.to_not change { trip.name }
            expect(response.code).to eq "200"
          end
        end
        context "guide who is not associated with this trip" do
          # TODO: Only a trip owner / guide who belongs to this trip's org can edit a trip
        end
      end
    end
  end
end
