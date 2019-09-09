module Onboardings
  class DestroyTrialGuestsJob < ApplicationJob
    queue_as :default

    SAFE_DEFAULT_TIME = 100.years.ago

    def perform(organisation)
      return unless organisation.onboarding_complete?

      @organisation = organisation
      trial_guests.destroy_all
    end

    private

    def trial_guests
      @organisation.guests.created_before(trial_ended_at)
    end

    def trial_ended_at
      @organisation.onboarding.find_event("trial_ended").presence["created_at"] || SAFE_DEFAULT_TIME
    end
  end
end
