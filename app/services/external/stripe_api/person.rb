module External
  # Encapsulates all Stripe API Connected Person functionality
  # Ref: https://stripe.com/docs/api/persons/
  module StripeApi
    class Person < External::StripeApi::Base
      # TODO: replace PII params with person token
      def initialize(account_id, person_params, use_test_api)
        @account_id = account_id
        @person_params = person_params
        @use_test_api = use_test_api
        initialize_key
      end

      # https://stripe.com/docs/api/persons/create
      def create
        Stripe::Account.create_person(
          @account_id,
          @person_params
        )
      end

      def self.create(account_id, person_params, use_test_api)
        new(account_id, person_params, use_test_api).create
      end
    end
  end
end
