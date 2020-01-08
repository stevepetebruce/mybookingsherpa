module External
  module StripeApi
    # refs: 
    # https://stripe.com/docs/api/setup_intents
    # https://stripe.com/docs/payments/setup-intents
    class SetupIntent < External::StripeApi::Base
      def initialize(use_test_api)
        @use_test_api = use_test_api
        initialize_key # TODO: replace with super?
      end

      def create(attributes)
        Stripe::SetupIntent.create(attributes)
      end

      def self.create(attributes, use_test_api: true)
        new(use_test_api).create(attributes)
      end
    end
  end
end

Stripe::SetupIntent.create(
  metadata: {
      booking_id: @booking.id,
      stripe_account_id: @booking.organisation_stripe_account_id,
      use_test_api: use_test_api?
  },
  payment_method_types: ["card"],
  usage: "off_session"
)