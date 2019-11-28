module Public
  module Trips
    class BookingsController < ApplicationController
      TIMEOUT_WINDOW_MINUTES = 30

      before_action :set_booking, only: %i[edit update show]
      before_action :check_timeout, only: %i[edit update show]
      before_action :set_trip, only: %i[create new]
      before_action :assign_current_organisation, only: %i[create edit new show update]
      before_action :assign_hide_in_trial_banner, only: %i[edit show]

      layout "public"

      # GET /bookings/new
      def new
        @booking = @trip.bookings.new
        @example_data = Onboardings::ExampleDataSelector.new(@trip.bookings.count)
        @payment_intent = Bookings::PaymentIntents.find_or_create(@booking)
      end

      # POST /bookings
      def create
        @guest = Guest.find_or_create_by(email: booking_params[:email])
        @booking = @trip.bookings.new(booking_params.merge(guest: @guest))
        @payment_intent = Bookings::PaymentIntents.find_or_create(@booking)

        attach_stripe_customer_to_guest

        @booking.organisation_on_trial? ? test_create : live_create
      end

      # GET /bookings/1/edit
      def edit
        @trip = @booking.trip
        @example_data = Onboardings::ExampleDataSelector.new(@trip.bookings.count - 1)
      end

      # PATCH/PUT /bookings/1
      def update
        if @booking.update(booking_params) && create_associations
          redirect_to url_for controller: "bookings",
                              action: "show",
                              id: @booking.id,
                              subdomain: @booking.organisation_subdomain_or_www,
                              tld_length: tld_length

        else
          @example_data = Onboardings::ExampleDataSelector.new(@booking.trip.bookings.count - 1)
          flash.now[:alert] = "Problem updating booking. #{@booking.errors.full_messages.to_sentence}"
          render :edit
        end
      end

      private

      def assign_current_organisation
        @current_organisation = @trip.organisation if defined? @trip
        @current_organisation ||= @booking.organisation
      end

      def assign_hide_in_trial_banner
        @booking ||= set_booking

        @hide_in_trial_banner = @booking.trip.bookings.count == 1 ? true : false
      end

      def live_create
        if @booking.save && update_or_create_payment
          successful_booking_jobs
          redirect_to url_for controller: "bookings",
                              action: "edit",
                              id: @booking.id,
                              subdomain: @booking.organisation_subdomain_or_www,
                              tld_length: tld_length
        # TODO:
        # else
        #   flash.now[:alert] = @stripe_api_error || @booking.errors.full_messages.to_sentence
        #   render :new
        end
      end

      def test_create
        @booking.save
        Payment.create(booking: @booking, amount: @booking.amount_due)

        successful_booking_jobs
        redirect_to url_for controller: "bookings",
                            action: "edit",
                            id: @booking.id,
                            subdomain: @booking.organisation_subdomain_or_www,
                            tld_length: tld_length
      end

      def allergies
        params.dig(:booking, :allergies)
      end

      def attach_stripe_customer_to_guest
        @booking.guest.update(stripe_customer_id: stripe_customer_id)
      end

      def booking_params
        params.require(:booking).
          permit(:address, :city, :country, :county, :other_information,
                 :date_of_birth, :email, :name, :next_of_kin_name,
                 :next_of_kin_phone_number, :phone_number, :post_code).
          reject { |_k, v| v.blank? }
      end

      def check_timeout
        return if newly_created?

        @booking.errors.add(:base, :timeout, message: "timed out please contact support")
        redirect_to url_for(controller: "bookings", action: "new", subdomain: @booking.organisation_subdomain_or_www, trip_id: @booking.trip_slug)
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

      def update_or_create_payment
        # TODO: Refactor... There's a possible race condition here:
        # When the Stripe webhook comes back at same time as this is called...
        # Then two payments would be created?
        # Move to delayed background job?
        Payment.transaction do
          Payment.where(stripe_payment_intent_id: stripe_payment_intent_id).
            first_or_create.
            update(booking: @booking)
        end
      end

      def set_booking
        @booking = Booking.find(params[:id])
      end

      def set_trip
        @trip = Trip.find_by_slug(params[:trip_id])
      end

      def stripe_customer_id
        # TODO: what if this is a returning customer?
        @stripe_customer_id ||= Bookings::StripeCustomer.new(@booking, stripe_payment_method).id
      end

      def stripe_payment_intent_id
        params[:payment_intent_id]
      end

      def stripe_payment_method
        params[:stripePaymentMethod]
      end

      def successful_booking_jobs
        # TODO: Add background jobs with sidekiq and redis to allow sending of emails in background job
        # ex: BookingMailer.with(booking: @booking).new.deliver_later(wait: 10.minutes)
        # 10 min wait to let them fill in their details in booking edit page, then send updated email
        # content based on that state...
        # TODO: Should we only send these when we get the webhook back from stripe with payment success?
        # Or send them straight out when in trial mode (both to guide)
        Guests::BookingMailer.with(booking: @booking).new.deliver_later
        Guides::BookingMailer.with(booking: @booking).new.deliver_later
      end

      def tld_length
        Settings.env_staging? ? 2 : 1
      end
    end
  end
end
