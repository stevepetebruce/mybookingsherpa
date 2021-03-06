module Bookings
  # Handles bookings' payment status.
  class PaymentStatus
    def initialize(booking)
      @booking = booking
    end

    def new_payment_status
      # TODO: add a way for the status to be :refunded - will need Stripe webhook
      return :payment_failed if @booking.last_payment_failed?
      return :payment_pending if payment_pending?
      return :payment_required if no_payments? || payment_required?
      return :payment_failed if @booking.last_failed_payment

      :full_amount_paid if full_amount_paid?
    end

    def payment_required?
      total_paid < @booking.full_cost
    end

    def total_paid
      @total_paid ||= @booking&.payments&.success&.pluck(:amount)&.compact&.reduce(:+)&.presence || 0
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

    def payment_pending?
      @booking.last_payment&.pending?
    end
  end
end
