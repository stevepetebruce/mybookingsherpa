module Onboardings
  class TrackEventJob < ApplicationJob
    queue_as :default

    def perform(onboarding, event, additional_info)
      onboarding.track_event(event, additional_info)
    end
  end
end
