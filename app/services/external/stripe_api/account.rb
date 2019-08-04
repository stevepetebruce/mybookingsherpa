module External
  # Encapsulates all Stripe API Connected Accounts functionality
  # Ref: https://stripe.com/docs/api/accounts
  module StripeApi
    class Account < External::StripeApi::Base
      def initialize(country, email)
      end

      def create
      end
    end
  end
end
