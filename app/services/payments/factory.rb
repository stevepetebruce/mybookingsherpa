module Payments
  # Creates a payment record for a booking using data from the card handler API.
  class Factory
    def initialize(booking, raw_response)
      @booking = booking
      @raw_response = raw_response
    end

    def create
      @booking.payments.create(amount: amount, raw_response: parsed_response)
    end

    private

    def amount
      parsed_response.fetch("amount")
    end

    def parsed_response
      @raw_response.to_h.stringify_keys
    end
  end
end
