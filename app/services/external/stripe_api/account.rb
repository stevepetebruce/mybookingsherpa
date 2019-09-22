module External
  module StripeApi
    # Encapsulates all Stripe API Connected Accounts functionality
    # Ref: https://stripe.com/docs/api/accounts
    class Account < External::StripeApi::Base
      def initialize(account_token)
        @account_token = account_token
        @use_test_api = false # We will never be creating these in the test API.
        initialize_key
      end

      # https://stripe.com/docs/connect/account-tokens#create-account
      def create
        Stripe::Account.create(account_token: @account_token,
                               requested_capabilities: ["card_payments", "transfers"],
                               type: "custom")
      end

      def self.create_live_account(account_token)
        new(account_token).create
      end

      def self.create_test_account(email, country_code)
        Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY_TEST")
        Stripe::Account.create(country: country_code.upcase,
                               email: email,
                               requested_capabilities: ["card_payments", "transfers"],
                               type: "custom")
      end
    end
  end
end
