module Bookings
  class UpdateSuccessfulPaymentJob
    include Sidekiq::Worker

    def perform(amount, stripe_payment_intent_id)
      @amount = amount
      @stripe_payment_intent_id = stripe_payment_intent_id

      raise_payment_without_booking_error unless payment.booking

      payment.update(amount: @amount, status: :success)
    end

    private

    # If, in exceptional case that, the delay allowed for booking creation is not long enough
    def raise_payment_without_booking_error
      raise PaymentWithoutBookingError, "Attempted to create a payment without an associated booking" \
        "Payment id: #{@payment_id} . StripePaymentIntent id: #{@stripe_payment_intent_id} . Amount: #{@amount} ."
    end

    def payment
      @payment ||=
        Payment.find_or_create_by(stripe_payment_intent_id: @stripe_payment_intent_id)
    end
  end

  class PaymentWithoutBookingError < StandardError; end
end
