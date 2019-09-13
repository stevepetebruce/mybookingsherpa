# frozen_string_literal: true

module External
  module StripeApi
    # Encapsulates all Stripe API Connected Accounts functionality
    # Ref: https://stripe.com/docs/api/external_account_bank_accounts
    # TODO: create an organisation wrapper service object that determines
    #   whether to use_test_api or not... based on it's trial status... 
    class ExternalAccount < External::StripeApi::Base
      def initialize(account_id, external_account_token)
        @account_id = account_id
        @external_account_token = external_account_token
        @use_test_api = false # We will never be creating these in the test API.
        initialize_key
      end

      # https://stripe.com/docs/api/external_account_bank_accounts/create
      def create
        Stripe::Account.
          create_external_account(@account_id,
                                  external_account: @external_account_token)
      end

      def self.create(account_id, external_account_token)
        new(account_id, external_account_token).create
      end
    end
  end
end
