module External
  module StripeApi
    # Create a URL to Stripe's hosted onboarding process
    # Ref: https://stripe.com/docs/api/account_links
    class AccountLink < External::StripeApi::Base
      def initialize(stripe_account_id, failure_url, success_url, type)
        @stripe_account_id = stripe_account_id
        @failure_url = failure_url
        @success_url = success_url
        @type = type
        @use_test_api = false # We will never be creating these in the test API.
        initialize_key # TODO: use super and initialize in base controller
      end

      def create
        Stripe::AccountLink.create({
          account: @stripe_account_id,
          collect: "eventually_due",
          failure_url: @failure_url,
          success_url: @success_url,
          type: @type
        }).url
      end

      def self.create(stripe_account_id, failure_url:, success_url:, type: "account_onboarding")
        new(stripe_account_id, failure_url, success_url, type).create
      end
    end
  end
end
