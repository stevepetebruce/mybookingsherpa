module External
  # Encapsulates all Stripe API Charge functionality
  # Ref: https://stripe.com/docs/charges
  module StripeApi
    class Charge < External::StripeApi::Base
      def initialize(amount, application_fee_amount, currency, customer, description, transfer_data, use_test_api)
        @amount = amount
        @application_fee_amount = application_fee_amount
        @currency = currency
        @customer = customer
        @description = description
        @transfer_data = transfer_data
        @use_test_api = use_test_api
        initialize_key
      end

      def charge
        Stripe::Charge.create(attributes)
      end

      def self.create(amount:, application_fee_amount:, currency:, customer:, description:, transfer_data:, use_test_api:)
        new(amount, application_fee_amount, currency, customer, description, transfer_data, use_test_api).charge
      end

      private

      def attributes
        {
          amount: @amount,
          application_fee_amount: @application_fee_amount,
          currency: @currency,
          customer: @customer,
          description: @description,
          transfer_data: @transfer_data
        }
      end
    end
  end
end
