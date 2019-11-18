module Public
  module Trips
    module Bookings
      class FailedPaymentsController < ApplicationController
        before_action :set_booking, only: %i[new create show]

        layout "public"

        # GET /public/trips/bookings/:booking_id/failed_payments/new
        def new
          @payment_intent = ::Bookings::PaymentIntents.find_or_create(@booking)
        end

        # POST /public/trips/bookings/:booking_id/failed_payments
        def create
          create_payment

          redirect_to url_for controller: "/public/trips/bookings/failed_payments",
                              action: "show",
                              subdomain: @booking.organisation_subdomain,
                              id: @booking.id
        end

        private

        def create_payment
          Payment.where(stripe_payment_intent_id: stripe_payment_intent_id).
            first_or_create.
            update(booking: @booking)
        end

        def set_booking
          @booking ||= Booking.find(params[:booking_id] || params[:id])
        end

        def stripe_payment_intent_id
          params[:payment_intent_id]
        end
      end
    end
  end
end
