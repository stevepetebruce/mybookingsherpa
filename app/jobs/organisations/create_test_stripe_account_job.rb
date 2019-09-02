module Organisations
  # Creates a basic test stripe account for an organisation
  class CreateTestStripeAccountJob < ApplicationJob
    queue_as :default

    def perform(organisation)
      organisation.update(stripe_account_id: test_stripe_account(organisation).id)
    end

    private

    def test_stripe_account(organisation)
      External::StripeApi::Account.create_test_account(organisation.owner.email)
    end
  end
end
