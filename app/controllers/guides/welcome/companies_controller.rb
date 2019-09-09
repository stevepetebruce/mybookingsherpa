module Guides
  module Welcome
    class CompaniesController < ApplicationController
      include Onboardings::Tracking
      layout "onboarding"

      before_action :authenticate_guide!
      before_action :set_current_organisation

      def new
        track_onboarding_event("new_company_account_chosen")
      end

      private

      def set_current_organisation
        # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
        @current_organisation ||= current_guide.organisation_memberships.owners.first.organisation
      end
    end
  end
end
