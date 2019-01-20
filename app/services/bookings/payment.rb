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
        amount: 999, # TODO: replace with: @booking.amount_due (4)
        currency: "eur", # TODO: replace with: @booking.currency
        description: "Example charge", # TODO: replace with: @booking.charge_description
        token: @token
      }
    end
  end
end
