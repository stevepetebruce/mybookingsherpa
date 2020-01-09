module Bookings
  class PayInitialCostJob
    include Sidekiq::Worker
    sidekiq_options queue: :default, retry: 0

    def perform(stripe_setup_intent_id)
      Bookings::PaymentIntents.create(booking(stripe_setup_intent_id))
    end

    private

    def booking(stripe_setup_intent_id)
      @booking ||= Booking.find_by_stripe_setup_intent_id(stripe_setup_intent_id)
    end
  end
end
