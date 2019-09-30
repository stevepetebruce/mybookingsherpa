module Onboardings
  class AllCompanyPeopleProvidedJob < ApplicationJob
    queue_as :default

    def perform(organisation, account_token)
      External::StripeApi::Account.new(account_token).update(organisation.stripe_account_id)
    end
  end
end
