module Bookings
  class UpdateFailedPaymentJob
    include Sidekiq::Worker

    def perform(stripe_payment_intent_id, amount)
      payment = Payment.find_by_stripe_payment_intent_id(stripe_payment_intent_id)

      payment.update(amount: amount, status: "failed")
    end
  end
end
