module Onboardings
  class OnboardingInitialisationJob < ApplicationJob
    queue_as :default

    def perform(organisation, ip_address)
      Onboardings::AssignCountrySpecificDataJob.perform_now(organisation, ip_address)
      Onboardings::CreateTestStripeAccountJob.perform_later(organisation) unless Rails.env.test?
    end
  end
end
