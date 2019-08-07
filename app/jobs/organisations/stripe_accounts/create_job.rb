module Organisations
  module StripeAccounts
    class CreateJob < ApplicationJob
      queue_as :default

      def perform(organisation, token_account)
        organisation.update(stripe_account_id: stripe_account(token_account).id)
      end

      private

      def stripe_account(token_account)
        @stripe_account ||= External::StripeApi::Account.create(token_account)
      end
    end
  end
end
