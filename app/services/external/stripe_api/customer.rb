module External
  module StripeApi
    # Encapsulates all Stripe API Customer functionality
    # Ref: https://stripe.com/docs/api/customers
    class Customer < External::StripeApi::Base
      def initialize(use_test_api)
        @use_test_api = use_test_api
        initialize_key
      end

      def self.clone(account:, payment_method:, use_test_api:)
        new(use_test_api).create(payment_method, account)
      end

      def self.create(payment_method:, use_test_api:)
        new(use_test_api).create(payment_method)
      end

      def self.retrieve(customer_id:, use_test_api:)
        new(use_test_api).retrieve(customer_id: customer_id)
      end

      def create(payment_method)
        Stripe::Customer.create(payment_method: payment_method)
      end

      def retrieve(customer_id:)
        Stripe::Customer.retrieve(customer_id)
      end
    end
  end
end
