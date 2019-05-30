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
        @booking = BookingDecorator.new(@trip.bookings.new)
      end

      # POST /bookings
      def create
        @guest = Guest.find_or_create_by(email: booking_params[:email])
        @booking = BookingDecorator.new(@trip.bookings.new(booking_params.merge(guest: @guest)))

        attach_stripe_customer_to_guest(@booking)

        if @booking.save && payment_successful?
          successful_booking_jobs
          redirect_to url_for(controller: "bookings", action: "edit", id: @booking.id, subdomain: @booking.organisation_subdomain, tld_length: 0)
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
          redirect_to url_for(controller: "bookings", action: "show", subdomain: @booking.organisation_subdomain, id: @booking.id)
        else
          render :edit
        end
      end

      private

      def attach_stripe_customer_to_guest(booking)
        booking.guest.update(stripe_customer_id: stripe_customer_id(booking))
      end

      def booking_params
        params.require(:booking).permit(:address, :allergies, :city, :country, :county,
                                        :date_of_birth, :dietary_requirements,
                                        :email, :name, :other_information,
                                        :next_of_kin_name, :next_of_kin_phone_number,
                                        :phone_number, :post_code)
      end

      def charge
        @charge ||= Bookings::Payment.new(@booking).charge
      end

      def check_timeout
        return if newly_created?

        @booking.errors.add(:base, :timeout, message: "timed out please contact support")
        redirect_to url_for(controller: "bookings", action: "new", subdomain: @booking.organisation_subdomain, trip_id: @booking.trip_id)
      end

      def newly_created?
        @booking.created_at > TIMEOUT_WINDOW_MINUTES.minutes.ago
      end

      def payment_successful?
        # TODO: surface Stripe errors to the user
        Payments::Factory.new(@booking, charge).create
      end

      def set_booking
        @booking = BookingDecorator.new(Booking.find(params[:id]))
      end

      def set_trip
        @trip = Trip.find_by_slug(params[:trip_id])
      end

      def stripe_customer_id(booking)
        Bookings::StripeCustomer.new(booking, stripe_token).id
      end

      def stripe_token
        params[:stripeToken]
      end

      def successful_booking_jobs
        # TODO: Add background jobs with sidekiq and redis to allow sending of emails in background job
        # ex: BookingMailer.with(booking: @booking).new.deliver_later(wait: 10.minutes)
        # 10 min wait to let them fill in their details in booking edit page, then send updated email
        # content based on that state...
        GuestBookingMailer.with(booking: @booking.__getobj__).new.deliver_later
        GuideBookingMailer.with(booking: @booking.__getobj__).new.deliver_later

        UpdateBookingStatusJob.perform_later(@booking.__getobj__)
      end
    end
  end
end
