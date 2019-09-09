# frozen_string_literal: true
module Guides
  module Welcome
    # The onboarding controller for creating bank accounts
    class BankAccountsController < ApplicationController
      include Onboardings::Tracking
      layout "onboarding"

      before_action :authenticate_guide!
      before_action :set_current_organisation

      def new; end

      def create
        # TODO: create / capture raw_stripe_api_response
        External::StripeApi::ExternalAccount.create(@current_organisation.stripe_account_id,
                                                    params[:token_account])
        track_onboarding_event("new_bank_account_created")
        # TODO: need to deal with a failed bank account creation...
        # TODO: this will be different when the organisation is a company with directors etc..
        @current_organisation.onboarding.update_columns(complete: true)
        redirect_to guides_trips_path
      end

      private

      def set_current_organisation
        # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
        @current_organisation ||= current_guide.organisation_memberships.owners.first.organisation
      end
    end
  end
end
