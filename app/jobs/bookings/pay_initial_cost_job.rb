module Bookings
  class PayInitialCostJob
    include Sidekiq::Worker

    def perform(stripe_setup_intent_id)
      Bookings::PaymentIntents.create(booking(stripe_setup_intent_id))
    end

    private

    def booking(stripe_setup_intent_id)
      @booking ||= Booking.find_by_stripe_setup_intent_id(stripe_setup_intent_id)
    end
  end
end
