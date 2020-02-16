module Bookings
  class UpdateFailedPaymentJob
    include Sidekiq::Worker

    def perform(booking_id, stripe_payment_intent_id, amount)
      booking = Booking.find(booking_id)
      payment = booking.
                  payments.
                  find_or_create_by(stripe_payment_intent_id: stripe_payment_intent_id)

      payment.update(amount: amount, status: "failed")
    end
  end
end
