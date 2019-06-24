module Bookings
  # Handles bookings' payment status.
  class PaymentStatus
    def initialize(booking)
      @booking = booking
    end

    def new_payment_status
      return :red if @booking.last_payment_failed?
      return :yellow if no_payments? || payment_required?

      :green if full_amount_paid?
    end

    def payment_required?
      total_paid < @booking.full_cost
    end

    def update
      @booking.update(payment_status: new_payment_status)
    end

    private

    def full_amount_paid?
      total_paid >= @booking.full_cost
    end

    def no_payments?
      @booking.payments.empty?
    end

    def total_paid
      @total_paid ||= @booking.payments.pluck(:amount).reduce(:+).presence || 0
    end
  end
end
