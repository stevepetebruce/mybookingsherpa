module Bookings
  # Handles time sensitive costs due based on trip deposit cost, full cost,
  # proximity to trip start date, etc.
  class CostCalculator
    def initialize(booking)
      @booking = booking
    end

    def amount_due
      calculate_amount_due
    end

    private

    def before_full_payment_window?
      (@booking.trip_start_date - @booking.trip_full_payment_window_weeks.weeks) >
        Time.zone.now
    end

    def calculate_amount_due
      return @booking.deposit_cost if deposit_due?

      @booking.full_cost
    end

    def deposit_due?
      return false if no_full_payment_window? || no_deposit_cost?

      before_full_payment_window?
    end

    def no_deposit_cost?
      @booking.deposit_cost.nil? || @booking.deposit_cost.zero?
    end

    def no_full_payment_window?
      @booking.trip_full_payment_window_weeks.blank?
    end
  end
end
