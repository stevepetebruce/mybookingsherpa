# frozen_string_literal: true
module Guides
  module Welcome
    # The onboarding controller for creating bank accounts
    class BankAccountsController < ApplicationController
      include Onboardings::Tracking
      before_action :assign_hide_in_trial_banner, only: %i[new]
      before_action :refresh_stripe_account_capabilities, only: %i[new]
      before_action :authenticate_guide!

      def new
        redirect_to guides_trips_path unless current_organisation.stripe_account_complete?
      end

      def create
        # TODO: create / capture raw_stripe_api_response
        External::StripeApi::ExternalAccount.create(current_organisation.stripe_account_id,
                                                    params[:token_account])
        track_onboarding_event("new_bank_account_created")
        onboarding_complete_tasks
        # TODO: need to deal with a failed bank account creation...
        redirect_to guides_trips_path(completed_set_up: true)
      end

      private

      def assign_hide_in_trial_banner
        @hide_in_trial_banner = true
      end

      def current_organisation
        # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
        @current_organisation ||= current_guide&.organisation_memberships&.owners&.first&.organisation
      end

      def onboarding_complete_tasks
        return if current_organisation.onboarding_complete? # Don't want to delete genuine bookings

        current_organisation.onboarding.update_columns(complete: true)
        track_onboarding_event("trial_ended")
        Onboardings::DestroyTrialGuestsJob.perform_later(current_organisation) 
      end

      def refresh_stripe_account_capabilities
        # Handles race condition where webhook confirming charges_enabled is sent too late
        return if current_organisation&.stripe_account_complete?
        return if current_organisation&.stripe_account_id.nil?

        current_organisation.onboarding.update(stripe_account_complete: stripe_account.charges_enabled)
      end

      def stripe_account
        @stripe_account ||= External::StripeApi::Account.retrieve(current_organisation.stripe_account_id)
      end
    end
  end
end
