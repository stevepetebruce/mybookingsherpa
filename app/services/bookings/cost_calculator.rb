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

    def self.amount_due(booking)
      new(booking).amount_due
    end

    private

    def after_full_payment_window?
      return false if full_payment_window_weeks.blank?

      (@booking.trip_start_date - full_payment_window_weeks.weeks) <
        Time.zone.now
    end

    def before_full_payment_window?
      return false if full_payment_window_weeks.blank?

      (@booking.trip_start_date - full_payment_window_weeks.weeks) >
        Time.zone.now
    end

    def calculate_amount_due
      return @booking.deposit_cost if deposit_due?
      return full_cost_minus_deposit if remainder_of_full_cost_due?
      return 0 if nothing_due_now?

      @booking.full_cost
    end

    def deposit_due?
      return false if no_full_payment_window? ||
                      no_deposit_cost? ||
                      deposit_paid?

      before_full_payment_window?
    end

    def deposit_paid?
      total_paid == @booking.deposit_cost
    end

    def full_cost_minus_deposit
      @booking.full_cost - @booking.deposit_cost
    end

    def full_payment_window_weeks
      @booking.trip_full_payment_window_weeks
    end

    def no_deposit_cost?
      @booking.deposit_cost.nil? || @booking.deposit_cost.zero?
    end

    def no_full_payment_window?
      full_payment_window_weeks.blank?
    end

    def nothing_due_now?
      !no_deposit_cost? && deposit_paid? && before_full_payment_window?
    end

    def remainder_of_full_cost_due?
      return true if deposit_paid? && after_full_payment_window?

      false
    end

    def total_paid
      @total_paid ||= Bookings::PaymentStatus.new(@booking).total_paid
    end
  end
end
