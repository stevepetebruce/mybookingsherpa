module External
  # Encapsulates all Stripe API Connected Person functionality
  # Ref: https://stripe.com/docs/api/persons/
  module StripeApi
    class Person < External::StripeApi::Base
      def initialize(account_id, person_token)
        @account_id = account_id
        @person_token = person_token
        @use_test_api = true
        initialize_key
      end

      # https://stripe.com/docs/api/persons/create
      def create
        Stripe::Account.create_person(
          @account_id,
          {
            person_token: @person_token
          }
        )
      end

      def self.create(account_id:, person_token:)
        new(account_id, person_token).create
      end
    end
  end
end
