module Public
  module Trips
    class BookingsController < ApplicationController
      TIMEOUT_WINDOW_MINUTES = 30

      before_action :set_booking, only: %i[edit update show]
      before_action :check_timeout, only: %i[edit update show]
      before_action :set_trip, only: %i[create new]
      before_action :assign_current_organisation, only: %i[edit new show update]

      layout "public"

      # GET /bookings/new
      def new
        @booking = @trip.bookings.new
      end

      # POST /bookings
      def create
        @guest = Guest.find_or_create_by(email: booking_params[:email])
        @booking = @trip.bookings.new(booking_params.merge(guest: @guest))

        if @booking.organisation_on_trial?
          test_create
        else
          live_create
        end
      end

      # GET /bookings/1/edit
      def edit
        @trip = @booking.trip
      end

      # PATCH/PUT /bookings/1
      def update
        if @booking.update(booking_params) && create_associations
          flash[:success] = "Booking updated"
          redirect_to url_for(controller: "bookings", action: "show", subdomain: @booking.organisation_subdomain, id: @booking.id)
        else
          flash.now[:alert] = "Problem updating booking. #{@booking.errors.full_messages.to_sentence}"
          render :edit
        end
      end

      private

      def assign_current_organisation
        @current_organisation = @trip.organisation if defined? @trip
        @current_organisation ||= @booking.organisation
      end

      def live_create
        attach_stripe_customer_to_guest(@booking)

        if @booking.save && payment_successful?
          successful_booking_jobs
          flash[:success] = "Payment successful"
          redirect_to url_for(controller: "bookings", action: "edit", id: @booking.id, subdomain: @booking.organisation_subdomain, tld_length: 0)
        else
          flash.now[:alert] = @stripe_api_error || @booking.errors.full_messages.to_sentence
          render :new
        end
      end

      def test_charge
        {
          amount: @booking.full_cost
        }
      end

      def test_create
        @booking.save
        Payments::Factory.new(@booking, test_charge).create
        successful_booking_jobs
        flash[:success] = "Payment successful"
        redirect_to url_for(controller: "bookings", action: "edit", id: @booking.id, subdomain: @booking.organisation_subdomain, tld_length: 0)
      end

      def allergies
        params.dig(:booking, :allergies)
      end

      def attach_stripe_customer_to_guest(booking)
        booking.guest.update(stripe_customer_id: stripe_customer_id(booking))
      end

      def booking_params
        params.require(:booking).
          permit(:address, :city, :country, :county, :other_information,
                 :date_of_birth, :email, :name, :next_of_kin_name,
                 :next_of_kin_phone_number, :phone_number, :post_code).
          reject { |_k, v| v.blank? }
      end

      def charge
        @charge ||= Bookings::Payment.new(@booking).charge
      end

      def check_timeout
        return if newly_created?

        @booking.errors.add(:base, :timeout, message: "timed out please contact support")
        redirect_to url_for(controller: "bookings", action: "new", subdomain: @booking.organisation_subdomain, trip_id: @booking.trip_slug)
      end

      def create_associations
        create_allergies && create_dietary_requirements
      end

      def create_allergies
        return true if allergies.nil? # else update fails when there's no allergies

        allergies&.each { |allergy| @booking.allergies.create(name: allergy) }
      end

      def create_dietary_requirements
        return true if dietary_requirements.nil? # else update fails when there's no dietary_requirements

        dietary_requirements&.each do |dietary_requirement|
          @booking.dietary_requirements.create(name: dietary_requirement)
        end
      end

      def dietary_requirements
        params.dig(:booking, :dietary_requirements)
      end

      def newly_created?
        @booking.created_at > TIMEOUT_WINDOW_MINUTES.minutes.ago
      end

      def payment_successful?
        begin
          Payments::Factory.new(@booking, charge).create
        rescue Stripe::CardError => e
          @stripe_api_error = "Payment unsuccessful. #{e&.json_body&.dig(:error, :message)}"
        rescue Stripe::StripeError => e
          @stripe_api_error = "Payment unsuccessful. #{type_of_exception(e)}. Please try again or contact Guide for help."
        end

        defined?(@stripe_api_error) ? false : true
      end

      def set_booking
        @booking = Booking.find(params[:id])
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
        Guests::BookingMailer.with(booking: @booking).new.deliver_later
        Guides::BookingMailer.with(booking: @booking).new.deliver_later
      end

      def type_of_exception(exception)
        exception.inspect.split(":").last.gsub(">", "")
      end
    end
  end
end
