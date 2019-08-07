module Guides
  module Welcome
    class SolosController < ApplicationController
      before_action :authenticate_guide!
      before_action :set_current_organisation

      # TODO: could do with an onboarding object... that determines what to show based on
      # current state of the @current_organisation ?
      # Or use the StripeAccount object, and save each raw_response... and status in there...?
      def new; end

      def create
        Organisations::StripeAccounts::CreateJob.perform_later(@current_organisation, params[:token_account])
        redirect_to new_guides_welcome_solo_path # ... need to work on the UX - need to add bank details now..
      end

      private

      def set_current_organisation
        # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
        @current_organisation ||= current_guide.organisation_memberships.owners.first.organisation
      end
    end
  end
end
