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

      def create
        if @current_organisation.update(stripe_account_id: stripe_account.id)
          # redirect_to new_guides_welcome_bank_account_path
          redirect_to new_guides_welcome_director_path
        else
          redirect_to new_guides_welcome_solo_path # need to expose any errors
        end
      end

      private

      def stripe_account
        # TODO: create / capture raw_stripe_api_response
        # TODO: move this to a background job? - and reveal to Guide any errors in my account view...?
        # Would then need another way (other than checking @current_organisation has stripe_account_id - in conditional "creating_stripe_account?" )
        @stripe_account ||= External::StripeApi::Account.create_live_account(params[:token_account])
      end

      def set_current_organisation
        # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
        @current_organisation ||= current_guide.organisation_memberships.owners.first.organisation
      end
    end
  end
end
