module External
  module StripeApi
    # Encapsulates all Stripe API Connected Accounts functionality
    # Ref: https://stripe.com/docs/api/accounts
    class Account < External::StripeApi::Base
      def initialize(account_number: nil, account_token: nil, country_code: nil, email: nil, use_test_api: false)
        @account_number = account_number
        @account_token = account_token
        @country_code = country_code
        @email = email
        @use_test_api = use_test_api

        initialize_key
      end

      def self.create_live_account(country_code, email)
        new(country_code: country_code, email: email).create_live_account
      end

      def self.create_live_account_from_token(account_token)
        new(account_token: account_token).create_live_account_from_token
      end

      def self.create_test_account(country_code, email)
        Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY_TEST")
        Stripe::Account.create(country: country_code.upcase,
                               email: email,
                               requested_capabilities: ["card_payments", "transfers"],
                               type: "custom")
      end

      def self.retrieve(account_number)
        new(account_number: account_number).retrieve
      end

      # https://stripe.com/docs/api/accounts/create
      def create_live_account
        Stripe::Account.create(country: @country_code,
                               email: @email,
                               requested_capabilities: ["card_payments", "transfers"],
                               type: "custom")
      end

      # https://stripe.com/docs/connect/account-tokens#create-account
      def create_live_account_from_token
        Stripe::Account.create(account_token: @account_token,
                               requested_capabilities: ["card_payments", "transfers"],
                               type: "custom")
      end

      def retrieve
        Stripe::Account.retrieve(@account_number)
      end

      def update(stripe_account_id)
        Stripe::Account.update(stripe_account_id, account_token: @account_token)
      end
    end
  end
end
