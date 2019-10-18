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

      def list(customer_id)
        Stripe::PaymentIntent.list(customer: customer_id)
      end

      def retrieve(payment_intent_id)
        Stripe::PaymentIntent.retrieve(payment_intent_id)
      end

      def update(payment_intent_id, attributes)
        Stripe::PaymentIntent.update(payment_intent_id, attributes)
      end

      def self.create(attributes, use_test_api: true)
        new(use_test_api).create(attributes)
      end

      def self.list(customer_id, use_test_api: true)
        new(use_test_api).list(customer_id)
      end

      def self.retrieve(payment_intent_id, use_test_api: true)
        new(use_test_api).retrieve(payment_intent_id)
      end

      def self.update(payment_intent_id, attributes, use_test_api: true)
        new(use_test_api).update(payment_intent_id, attributes)
      end
    end
  end
end
