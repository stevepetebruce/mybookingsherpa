module External
  module StripeApi
    # ref: https://stripe.com/docs/payments/payment-intents/web
    class PaymentIntent < External::StripeApi::Base
      def initialize(attributes, use_test_api)
        @attributes = attributes
        @use_test_api = use_test_api
        initialize_key # TODO: replace with super?
      end

      def create
        Stripe::PaymentIntent.create(sanitized_attributes)
      end

      def self.create(attributes, use_test_api: true)
        new(attributes, use_test_api).create
      end

      private

      def sanitized_attributes
        @attributes.map do |k, v|
          if k == :statement_descriptor
            [k, v.gsub(/[^a-zA-Z\s\\.]/, "_")]
          else
            [k, v]
          end
        end.to_h
      end
    end
  end
end
