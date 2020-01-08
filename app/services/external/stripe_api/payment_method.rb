module External
  module StripeApi
    # ref: https://stripe.com/docs/api/payment_methods
    class PaymentMethod < External::StripeApi::Base
      def initialize(use_test_api)
        @use_test_api = use_test_api
        initialize_key # TODO: replace with super?
      end

      def create(customer, payment_method, account)
        Stripe::PaymentMethod.create({
          customer: customer,
          payment_method: payment_method,
          }, stripe_account: account)
      end

      def list(customer_id)
        Stripe::PaymentMethod.list(customer: customer_id, type: "card")
      end

      def self.list(customer_id, use_test_api: true)
        new(use_test_api).list(customer_id)
      end

      # Ref: https://stripe.com/docs/payments/payment-methods/connect#cloning-payment-methods
      def self.clone(account:, customer:, payment_method: nil, use_test_api: true)
        new(use_test_api).create(customer, payment_method, account)
      end
    end
  end
end
