# frozen_string_literal: true
module Guides
  module Welcome
    # The onboarding controller for creating bank accounts
    class BankAccountsController < ApplicationController
      include Onboardings::Tracking
      before_action :assign_hide_in_trial_banner, only: %i[new]
      before_action :assign_current_organisation
      before_action :authenticate_guide!

      def new
        redirect_to guides_trips_path unless only_bank_account_required?
      end

      def create
        # TODO: create / capture raw_stripe_api_response
        if bank_account_created?
          bank_account_complete_tasks

          redirect_to guides_trips_path(completed_set_up: true)
        else
          track_onboarding_event("new_bank_account_creation_failed")
          flash.now[:alert] = "Problem creating bank account. Please try again or contact support."
          render "new"
        end
      end

      private

      def assign_hide_in_trial_banner
        @hide_in_trial_banner = true
      end

      def bank_account_created?
        # Ref: https://stripe.com/docs/api/external_account_bank_accounts/object#account_bank_account_object-status
        stripe_external_account.status == "new"
      end

      def bank_account_complete_tasks
        return if @current_organisation.onboarding_complete? # Don't want to delete genuine bookings

        track_onboarding_event("new_bank_account_created")
        @current_organisation.onboarding.update(bank_account_complete: true,
                                                stripe_account_complete: stripe_account_complete?)

        if @current_organisation.onboarding.reload.complete?
          track_onboarding_event("trial_ended")
          Onboardings::DestroyTrialGuestsJob.perform_later(@current_organisation)
        end
      end

      def assign_current_organisation
        # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
        @current_organisation ||= current_guide&.organisation_memberships&.owners&.first&.organisation
      end

      def only_bank_account_required?
        stripe_account_requirements == ["external_account"] || stripe_account_requirements.empty?
      end

      def stripe_account
        @stripe_account ||=
          External::StripeApi::Account.retrieve(@current_organisation.stripe_account_id_live)
      end

      def stripe_account_complete?
        stripe_account.charges_enabled && stripe_account.payouts_enabled
      end

      def stripe_account_requirements
        @stripe_account_requirements ||= stripe_account.requirements.currently_due
      end

      def stripe_external_account
        @stripe_external_account ||=
          External::StripeApi::ExternalAccount.create(@current_organisation.stripe_account_id_live,
                                                      params[:token_account])
      end
    end
  end
end
