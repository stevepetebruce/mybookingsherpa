require 'rails_helper'

RSpec.describe 'Public::Trips::BookingsController', type: :request do
  describe '#show GET /public/bookings/:id' do
    let(:booking) { FactoryBot.create(:booking)}

    def do_request(url: "/public/bookings/#{booking.id}", params: {})
      get url, params: params
    end

    it 'should successfully render' do
      do_request

      expect(response).to be_successful
    end
  end

  describe '#new GET /public/bookings/new' do
    let(:trip)  { FactoryBot.create(:trip) }

    def do_request(url: "/public/trips/#{trip.id}/bookings/new", params: {})
      get url, params: params
    end

    it 'should successfully render' do
      do_request

      expect(response).to be_successful
    end
  end

  describe '#edit GET /bookings/:id/edit' do
    let(:booking) { FactoryBot.create(:booking)}

    def do_request(url: "/public/bookings/#{booking.id}/edit", params: {})
      get url, params: params
    end

    it 'should successfully render' do
      do_request

      expect(response).to be_successful
    end
  end

  describe '#create POST /public/trips/:trip_id/bookings' do
    let(:booking) { Booking.last }
    let(:trip)  { FactoryBot.create(:trip) }
    # TODO: Replace this, we want to only be able to change status in the backend
    let(:params) { { booking: { status: :complete } } }

    def do_request(url: "/public/trips/#{trip.id}/bookings", params: {})
      post url, params: params
    end

    it 'should create the booking' do
      expect { do_request(params: params) }.to change { trip.reload.bookings.count }.by(1)

      expect(response.code).to eq '302'
      expect(response).to redirect_to(public_booking_path(booking))
    end
  end

  describe '#update PATCH /bookings/:id' do
    let(:booking) { FactoryBot.create(:booking) }
    # TODO: Replace this, we want to only be able to change status in the backend
    let(:params) { { booking: { status: :complete } } }

    def do_request(url: "/public/bookings/#{booking.id}", params: {})
      patch url, params: params
    end

    it 'should update the booking' do
      do_request(params: params)

      expect(response.code).to eq '302'
      expect(response).to redirect_to(public_booking_path(booking))
    end
  end

  # TODO: Both of these cases (below) will be for non-public / secure area of app, not public.
  # TODO: index: will show all of a guests or guides bookings...
  # TODO: destroy, a guest or guide might want to manually delete a booking... soft delete?
end
