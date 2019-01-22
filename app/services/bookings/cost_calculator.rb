module Bookings
  # Handles time sensitive costs due based on trip deposit cost, full cost,
  # proximity to trip start date, etc.
  class CostCalculator
    def initialize(booking)
      @booking = booking
    end

    def amount_due_in_cents
      (amount_due * 100).to_i
    end

    def amount_due
      calculate_amount_due
    end

    private

    def calculate_amount_due
      @booking.full_cost
      # TODO:
      # At some point this will need to know
      # if to make a payment that is the deposit,
      # or the full payment. Will need to create
      # a customer for this, ie: to make one charge
      # now (deposit) and another full amount later.
      # Ref: https://stripe.com/docs/saving-cards
      # Then once the full payment has been made - delete the users’ card data
      # Safest thing to do here.
      # TODO: Need to be careful if we ever handle JPY (a zero-decimal currency)
    end
  end
end
