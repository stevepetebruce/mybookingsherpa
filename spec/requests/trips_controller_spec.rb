require 'rails_helper'

RSpec.describe 'TripsController', type: :request do
  # TODO: * need to test signed out users get redirected to sign in page/ public view of trip
  # ... need to add a nested public scope to trips
  # TODO: ** implement created_by and updated_by and test them here

  describe '#create POST /trips' do
    include_examples 'authentication'    

    def do_request(url: "/trips", params: {})
      post url, params: params
    end

    context 'valid and successful' do
      let(:params) { { trip: { name: Faker::Name.name } } }
      let(:trip) { Trip.last }

      it 'should create a new trip' do
        pending 'only a signed in guide can create a trip'
        # TODO: need to test that created trip is associated with current_guide
        expect { do_request(params: params) }.to change { Trip.count }.by(1)

        expect(response.code).to eq '302'
        expect(response).to redirect_to(trip_path(trip))

        expect(trip.name).to eq params[:trip][:name]
        # TODO: ** expect(trip.created_by).to eq user
        # TODO: ** expect(trip.updated_by).to eq user
      end
    end
  end

  describe '#destroy DELETE /trips' do
  # include_examples 'authentication'
  # Soft delete?
  # let!(:trip) { create(:trip) }

  # def do_request(url: "/trips/#{trip.id}", params: {})
  #   delete url, params: params
  # end

  # context 'signed in' do
  #   before do
  #     sign_in user
  #     stub_vault_submission_post
  #   end

  #   context 'trip sucessfully deleted' do
  #     it 'should be deleted' do
  #       expect { do_request }.to change { trip.count }.by(-1)

  #       expect(response.code).to eq '302'
  #     end
  #   end
  # end
  # TODO: ** expect(trip.updated_by).to eq user
  end

  describe '#edit GET /trips/:id/edit' do
    include_examples 'authentication'

    # Only a trip owner / guide who belongs to this trip's org can edit a trip?
    let(:trip) { FactoryBot.create(:trip) }

    def do_request(url: "/trips/#{trip.id}/edit", params: {})
      get url, params: params
    end

    context 'valid and successful' do
      it 'should successfully render' do
        pending 'see notes above'
        do_request

        expect(response).to be_successful
      end
    end
  end

  describe '#update PATCH /trips/:id' do
    include_examples 'authentication'
    # Only a trip owner / guide who belongs to this trip's org can edit a trip?
    let(:trip) { FactoryBot.create(:trip) }

    def do_request(url: "/trips/#{trip.id}", params: {})
      patch url, params: params
    end

    context 'valid and successful' do
      let(:params) { { trip: { name: Faker::Name.name } } }

      it 'should update the trip name' do
        pending 'see notes above'
        expect { do_request(params: params) }.to change { trip.reload.name }.to(params[:trip][:name])
      end

      # TODO: ** it 'should update the trip updated_by' do
      #   expect { do_request(params: params) }.to change { trip.reload.updated_by }.to(user)
      # end
    end
  end
end
