module Bookings
  # Creates Stripe setup_intents to collect and authorise card/ payment methods
  # ref: https://stripe.com/docs/api/setup_intents/create
  class SetupIntents
    def initialize(booking)
      @booking = booking
    end

    def create
      External::StripeApi::SetupIntent.create(attributes, use_test_api: use_test_api?)
    end

    def self.create(booking)
      new(booking).create
    end

    private

    def attributes
      {
        metadata: {
          booking_id: @booking.id,
          stripe_account_id: @booking.organisation_stripe_account_id,
          use_test_api: use_test_api?
        },
        payment_method_types: ["card"],
        usage: "off_session"
      }
    end

    def use_test_api?
      @booking.organisation_on_trial?
    end
  end
end
