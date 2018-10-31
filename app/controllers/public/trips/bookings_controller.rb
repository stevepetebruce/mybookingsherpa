module Public
  module Trips
    class BookingsController < ApplicationController
      skip_before_action :authenticate_guide!
      before_action :set_booking, only: [:show, :edit, :update]
      before_action :set_trip, only: [:create, :new]
      before_action :set_guest, only: [:create]

      # GET /bookings/1
      def show
      end

      # GET /bookings/new
      def new
        @booking = Booking.new
      end

      # GET /bookings/1/edit
      def edit
      end

      # POST /bookings
      def create
        @booking = @trip.bookings.new(booking_params.merge(guest: @guest))

        if @booking.save
          redirect_to edit_public_guest_path(@guest), notice: 'Booking was successfully created.'
        else
          render :new
        end
      end

      # PATCH/PUT /bookings/1
      def update
        if @booking.update(booking_params)
          redirect_to public_booking_path(@booking), notice: 'Booking was successfully updated.'
        else
          render :edit
        end
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_booking
        @booking = Booking.find(params[:id])
      end

      def set_guest
        @guest = Guest.find_or_create_by!(email: guest_params[:email])
      end

      def set_trip
        @trip = Trip.find(params[:trip_id])
      end

      # Only allow a trusted parameter "white list" through.
      def booking_params
        params.require(:booking).permit()
      end

      def guest_params
        params.require(:booking).permit(:email)
      end
    end
  end
end
