module Bookings
  class AttachStripePaymentMethodAndCustomerJob
    include Sidekiq::Worker

    def perform(stripe_payment_method_id, stripe_customer_id, stripe_setup_intent_id)
      booking(stripe_setup_intent_id).update(stripe_customer_id: stripe_customer_id,
                                             stripe_payment_method_id: stripe_payment_method_id)
    end

    private

    def booking(stripe_setup_intent_id)
      Booking.find_by_stripe_setup_intent_id(stripe_setup_intent_id)
    end
  end
end
