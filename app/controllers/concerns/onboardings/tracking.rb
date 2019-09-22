module Onboardings
  module Tracking
    extend ActiveSupport::Concern

    def track_onboarding_event(event, additional_info = nil)
      Onboardings::TrackEventJob.perform_later(@current_organisation.onboarding, event, additional_info)
    end
  end
end
