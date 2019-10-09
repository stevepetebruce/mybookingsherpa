module Webhooks
  module StripeApi
    class AccountsController < ApplicationController
      def create
        # TODO: put this in a background job?
        # TODO: check for some sense of non-malicious data... validate format?
        # https://stripe.com/docs/webhooks/signatures
        update_stripe_account_complete
        head :ok
      end

      private

      def organisation
        @organisation ||= Organisation.find_by_stripe_account_id(stripe_account_id)
      end

      def stripe_account_complete?
        # TODO: marshall the result - so it defaults to false is there's an error, etc...
        params["data"].dig("object", "charges_enabled") || false
      end

      def stripe_account_id
        params["account"]
      end

      def update_stripe_account_complete
        organisation.onboarding.update(stripe_account_complete: stripe_account_complete?)
      end
    end
  end
end
