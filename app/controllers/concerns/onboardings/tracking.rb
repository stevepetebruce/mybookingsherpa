module Onboardings
  module Tracking
    extend ActiveSupport::Concern

    def track_onboarding_event(event, additional_info = nil)
      @current_organisation.onboarding.track_event(event, additional_info)
    end
  end
end
