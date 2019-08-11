module External
  module StripeApi
    # Encapsulates all Stripe API Connected Accounts functionality
    # Ref: https://stripe.com/docs/api/accounts
    class Account < External::StripeApi::Base
      # TODO: create an organisation wrapper service object that determines
      #   whether to use_test_api or not... based on it's trial status... 
      def initialize(account_token, use_test_api = true)
        @account_token = account_token
        @use_test_api = true
        initialize_key
      end

      # https://stripe.com/docs/connect/account-tokens#create-account
      def create
        Stripe::Account.create(account_token: @account_token, type: "custom")
      end

      def self.create(account_token)
        new(account_token).create
      end
    end
  end
end
