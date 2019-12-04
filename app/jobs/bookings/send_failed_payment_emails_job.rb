module Bookings
  class SendFailedPaymentEmailsJob
    include Sidekiq::Worker

    def perform(stripe_payment_intent_id, payment_failure_message)
      @stripe_payment_intent_id = stripe_payment_intent_id

      Guests::FailedPaymentMailer.
        with(booking: booking, payment_failure_message: payment_failure_message).
        new.deliver_later
      Guides::FailedPaymentMailer.
        with(booking: booking, payment_failure_message: payment_failure_message).
        new.deliver_later
    end

    private

    def booking
      @booking ||= payment.booking
    end

    def payment
      @payment ||= Payment.find_by_stripe_payment_intent_id(@stripe_payment_intent_id)
    end
  end
end
