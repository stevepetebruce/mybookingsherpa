module Public
  module Trips
    class BookingsController < ApplicationController
      TIMEOUT_WINDOW_MINUTES = 30
      skip_before_action :authenticate_guide! # / :authenticate_guest! ?
      before_action :set_booking, only: %i[edit update show]
      before_action :check_timeout, only: %i[edit update show]
      before_action :set_trip, only: %i[create new]

      layout 'public'

      # GET /bookings/new
      def new
        @booking = Booking.new
      end

      # POST /bookings
      def create
        @guest = Guest.find_or_create_by!(email: booking_params[:email])
        @booking = @trip.bookings.new(booking_params.merge(guest: @guest))

        if @booking.save && create_charge
          redirect_to edit_public_booking_path(@booking), notice: 'Booking was successfully created.'
        else
          render :new
        end
      end

      # GET /bookings/1/edit
      def edit
        @trip = @booking.trip
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

      def booking_params
        params.require(:booking).permit(:email)
      end

      def check_timeout
        return if newly_created?

        @booking.errors.add(:base, :timeout, message: 'timed out please contact support')
        redirect_back(fallback_location: new_public_trip_booking_path(@booking.trip))
      end

      def create_charge
        Bookings::Payment.new(@booking, stripe_token).charge
      end

      def newly_created?
        @booking.created_at > TIMEOUT_WINDOW_MINUTES.minutes.ago
      end

      def set_booking
        @booking = Booking.find(params[:id])
      end

      def set_trip
        @trip = Trip.find(params[:trip_id])
      end

      def stripe_token
        params[:stripeToken]
      end
    end
  end
end
