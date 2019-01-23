module Bookings
  # Handles all bookings' payment business logic.
  class Payment
    def initialize(booking, token)
      @booking = booking
      @token = token
    end

    def charge
      External::StripeApi.new(attributes).charge
    end

    private

    def attributes
      {
        amount: Bookings::CostCalculator.new(@booking).amount_due_in_cents,
        currency: @booking.currency,
        description: charge_description,
        token: @token
      }
      # TODO: add platform fee and destination account
    end

    def charge_description
      "#{Currency.iso_to_symbol(@booking.currency)}" \
        "#{Bookings::CostCalculator.new(@booking).amount_due} " \
        "paid to #{@booking.organisation_name} for #{@booking.trip_name}"
    end
  end
end
