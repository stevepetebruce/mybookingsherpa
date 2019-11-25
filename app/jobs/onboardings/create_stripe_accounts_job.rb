module Onboardings
  # Creates both test and live stripe accounts for an organisation
  class CreateStripeAccountsJob < ApplicationJob
    queue_as :default

    def perform(organisation)
      organisation.update(stripe_account_id_test: stripe_account_test(organisation).id,
                          stripe_account_id_live: stripe_account_live(organisation).id)
    end

    private

    def stripe_account_test(organisation)
      External::StripeApi::Account.
        create_test_account(organisation.country_code,
                            organisation.owner.email)
    end

    def stripe_account_live(organisation)
      External::StripeApi::Account.
        create_live_account(organisation.country_code,
                            organisation.owner.email)
    end 
  end
end
