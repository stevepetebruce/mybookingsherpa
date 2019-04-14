module Public
  module Trips
    class BookingsController < ApplicationController
      TIMEOUT_WINDOW_MINUTES = 30

      before_action :set_booking, only: %i[edit update show]
      before_action :check_timeout, only: %i[edit update show]
      before_action :set_trip, only: %i[create new]

      layout "public"

      # GET /bookings/new
      def new
        @booking = @trip.bookings.new
      end

      # POST /bookings
      def create
        @guest = Guest.find_or_create_by(email: booking_params[:email])
        @booking = @trip.bookings.new(booking_params.merge(guest: @guest))

        if @booking.save && payment_successful?
          successful_booking_jobs
          redirect_to edit_public_booking_path(@booking)
        else
          # TODO: surface Stripe errors to the user
          # https://stripe.com/docs/api/errors
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
          redirect_to public_booking_path(@booking)
        else
          render :edit
        end
      end

      private

      def booking_params
        params.require(:booking).permit(:address, :allergies, :city, :country, :county,
                                        :date_of_birth, :dietary_requirements,
                                        :email, :name, :other_information,
                                        :next_of_kin_name, :next_of_kin_phone_number,
                                        :phone_number, :post_code)
      end

      def charge
        @charge ||= Bookings::Payment.new(@booking, stripe_token).charge
      end

      def check_timeout
        return if newly_created?

        @booking.errors.add(:base, :timeout, message: "timed out please contact support")
        redirect_to new_public_trip_booking_path(@booking.trip)
      end

      def newly_created?
        @booking.created_at > TIMEOUT_WINDOW_MINUTES.minutes.ago
      end

      def payment_successful?
        # TODO: surface Stripe errors to the user
        Payments::Factory.new(@booking, charge).create
      end

      def set_booking
        @booking = Booking.find(params[:id])
      end

      def set_trip
        @trip = Trip.find_by_slug(params[:trip_id])
      end

      def stripe_token
        params[:stripeToken]
      end

      def successful_booking_jobs
        # TODO: Add background jobs with sidekiq and redis to allow sending of emails in background job
        # ex: BookingMailer.with(booking: @booking).new.deliver_later(wait: 10.minutes)
        # 10 min wait to let them fill in their details in booking edit page, then send updated email
        # content based on that state...
        GuestBookingMailer.with(booking: @booking).new.deliver_later
        GuideBookingMailer.with(booking: @booking).new.deliver_later

        UpdateBookingStatusJob.perform_later(@booking)
      end
    end
  end
end
