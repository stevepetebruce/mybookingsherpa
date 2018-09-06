require 'rails_helper'

RSpec.describe 'TripsController', type: :request do
  # TODO: * need to test signed out users get redirected to sign in page/ public view of trip
  # TODO: ** implement created_by and updated_by and test them here

  describe '#create POST /trips' do
    def do_request(url: "/trips", params: {})
      post url, params: params
    end

    # TODO: * include_examples 'authentication' # signed out specs

    context 'valid and succesful' do
      let(:params) { { trip: { name: Faker::Name.name } } }
      let(:trip) { Trip.last }

      it 'should create a new trip' do
        expect { do_request(params: params) }.to change { Trip.count }.by(1)

        expect(response.code).to eq '302'
        expect(response).to redirect_to(trip_path(trip))

        expect(trip.name).to eq params[:trip][:name]
        # TODO: ** expect(clipping.created_by).to eq user
      end
    end
  end

  # TODO:
  # describe '#destroy DELETE /clippings' do
  #   let!(:clipping) { create(:clipping, workspace: workspace) }

  #   def do_request(url: "/#{workspace.slug}/#{brand.to_param}/clippings/#{clipping.id}", params: {})
  #     delete url, params: params
  #   end

  #   include_examples 'authentication'
  #   include_examples 'authorised workspace'

  #   context 'signed in' do
  #     before do
  #       sign_in user
  #       stub_vault_submission_post
  #     end

  #     context 'draft clip belonging to correct workspace' do
  #       it 'should be deleted' do
  #         expect { do_request }.to change { Clipping.count }.by(-1)

  #         expect(response.code).to eq '302'
  #       end
  #     end

  #     context 'draft clip belonging to another workspace' do
  #       let!(:clipping) { create(:clipping) }

  #       it 'should not be deleted' do
  #         expect { do_request }.to_not change { Clipping.count }
  #         expect(response.code).to eq '404'
  #       end
  #     end
  #   end
  # end

  describe '#edit GET /trips/:id/edit' do
    let(:trip) { FactoryBot.create(:trip) }

    def do_request(url: "/trips/#{trip.id}/edit", params: {})
      get url, params: params
    end

    # TODO: * include_examples 'authentication'
    context 'valid and succesful' do
      it 'should successfully render' do
        do_request

        expect(response).to be_successful
      end
    end
  end

  describe '#update PATCH /clippings/:id' do
    let(:trip) { FactoryBot.create(:trip) }

    def do_request(url: "/trips/#{trip.id}", params: {})
      patch url, params: params
    end

    # TODO: * include_examples 'authentication'

    context 'valid and succesful' do
      let(:params) { { trip: { name: Faker::Name.name } } }

      it 'should update the trip name' do
        expect { do_request(params: params) }.to change { trip.reload.name }.to(params[:trip][:name])
      end

      # TODO: ** it 'should update the trip updated_by' do
      #   expect { do_request(params: params) }.to change { trip.reload.updated_by }.to(user)
      # end
    end
  end
end
