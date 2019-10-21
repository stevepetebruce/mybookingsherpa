module External
  module StripeApi
    # ref: https://stripe.com/docs/payments/payment-intents/web
    class PaymentIntent < External::StripeApi::Base
      def initialize(use_test_api)
        @use_test_api = use_test_api
        initialize_key # TODO: replace with super?
      end

      def create(attributes)
        Stripe::PaymentIntent.create(attributes)
      end

      def self.create(attributes, use_test_api: true)
        new(use_test_api).create(attributes)
      end
    end
  end
end
