module Public
  module Trips
    module Bookings
      class FailedPaymentsController < ApplicationController
        before_action :set_booking, only: %i[new create show]

        layout "public"

        # GET /public/bookings/:booking_id/failed_payments/new
        def new
          @payment_intent = ::Bookings::PaymentIntents.find_or_create(@booking)
        end

        # POST /public/bookings/:booking_id/failed_payments
        def create
          # TODO: handle in session/ live failure?
          redirect_to url_for(controller: "/public/trips/bookings/failed_payments",
                              action: "show",
                              id: @booking.id,
                              subdomain: @booking.organisation_subdomain_or_www,
                              tld_length: tld_length)
        end

        private

        def set_booking
          @booking ||= Booking.find(params[:booking_id] || params[:id])
        end

        def tld_length
          Settings.env_staging? ? 2 : 1
        end
      end
    end
  end
end
