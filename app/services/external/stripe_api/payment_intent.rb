module External
  module StripeApi
    # ref: https://stripe.com/docs/payments/payment-intents/web
    # https://stripe.com/docs/api/payment_intents
    class PaymentIntent < External::StripeApi::Base
      def initialize(use_test_api)
        @use_test_api = use_test_api
        initialize_key # TODO: replace with super?
      end

      def create(attributes, stripe_account_id)
        return if amount_zero?(attributes)

        if stripe_account_id
          Stripe::PaymentIntent.create(sanitized_attributes(attributes), stripe_account: stripe_account_id) 
        else
          Stripe::PaymentIntent.create(sanitized_attributes(attributes))
        end
      end

      def retrieve(payment_intent_id)
        Stripe::PaymentIntent.retrieve(payment_intent_id)
      end

      def self.create(attributes, stripe_account_id = nil, use_test_api: true)
        puts ' - - - -- - - -- - - -'
        puts '!!! - create attributes ' + attributes.inspect
        new(use_test_api).create(attributes, stripe_account_id)
      end

      def self.retrieve(payment_intent_id, use_test_api: true)
        new(use_test_api).retrieve(payment_intent_id)
      end

      private

      def amount_zero?(attributes)
        sanitized_attributes(attributes)[:amount].zero?
      end

      def sanitized_attributes(attributes)
        attributes.map do |k, v|
          if k == :statement_descriptor_suffix
            [k, v.gsub(/[^a-zA-Z0-9\s\\.]/, "_")]
          else
            [k, v]
          end
        end.to_h
      end
    end
  end
end
