module External
  module StripeApi
    # Encapsulates all Stripe API Customer functionality
    # Ref: https://stripe.com/docs/api/customers
    class Customer < External::StripeApi::Base
      def initialize(use_test_api)
        @use_test_api = use_test_api
        initialize_key
      end

      def self.create(description:, use_test_api:)
        new(use_test_api).create(description: description)
      end

      def self.retrieve(customer_id:, use_test_api:)
        new(use_test_api).retrieve(customer_id: customer_id)
      end

      def create(description:)
        Stripe::Customer.create(description: description)
      end

      def retrieve(customer_id:)
        Stripe::Customer.retrieve(customer_id)
      end
    end
  end
end
