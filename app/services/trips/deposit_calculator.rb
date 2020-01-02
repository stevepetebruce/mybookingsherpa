module Trips
  # Calculates the actual deposit amount due for a trip
  #   based on trip's deposit_percentage and full_cost
  class DepositCalculator
    def initialize(trip)
      @trip = trip
    end

    def calculate_deposit
      deposit_rounded_up_in_cents
    end

    def self.calculate_deposit(trip)
      new(trip).calculate_deposit
    end

    private

    def deposit
      @trip.full_cost * (@trip.deposit_percentage.to_f / 100)
    end

    def deposit_as_decimal
      deposit / 100
    end

    def deposit_rounded_up
      deposit_as_decimal.ceil()
    end

    def deposit_rounded_up_in_cents
      deposit_rounded_up * 100
    end
  end
end
