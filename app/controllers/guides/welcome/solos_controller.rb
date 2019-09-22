# frozen_string_literal: true
module Guides
  module Welcome
    # The onboarding controller for solo founder guides
    class SolosController < Guides::Welcome::BaseController
      include Onboardings::Tracking
      layout "onboarding"
      before_action :authenticate_guide!
      before_action :set_current_organisation

      def create
        track_onboarding_event("new_solo_account_chosen")

        if create_stripe_account
          track_onboarding_event("new_stripe_account_created")
          redirect_to new_guides_welcome_bank_account_path
        else
          track_onboarding_event("failed_new_stripe_account_creation", error_message)
          flash.now[:alert] = "Problem creating account. #{error_message}"
          render :new
        end
      end
    end
  end
end
