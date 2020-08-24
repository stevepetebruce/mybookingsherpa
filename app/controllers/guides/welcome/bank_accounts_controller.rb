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
        if bank_account_not_set_up?
          render :new
        else
          redirect_to guides_trips_path(just_completed_set_up: just_completed_set_up?) and return
        end
      end

      def create
        # TODO: create / capture raw_stripe_api_response
        if bank_account_created?
          track_onboarding_event("new_bank_account_created")
          @current_organisation.onboarding.update(bank_account_complete: true)
          redirect_to guides_trips_path(just_completed_set_up: just_completed_set_up?)
        else
          track_onboarding_event("new_bank_account_creation_failed")
          flash.now[:alert] = "Problem creating bank account. Please try again or contact support."
          render "new"
        end
      end

      # def edit
      #   # TODO: will be when the guide needs to edit their bank account
      # end

      private

      def assign_hide_in_trial_banner
        @hide_in_trial_banner = true
      end

      def bank_account_created?
        # Ref: https://stripe.com/docs/api/external_account_bank_accounts/object#account_bank_account_object-status
        stripe_external_account.status == "new"
      end

      def just_completed_set_up?
        @current_organisation.onboarding.just_completed_set_up?
      end

      def assign_current_organisation
        # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
        @current_organisation ||= current_guide&.organisation_memberships&.owners&.first&.organisation
      end

      def bank_account_not_set_up?
        stripe_account_requirements.include?("external_account")
      end

      def identity_verification_required?
        stripe_account_requirements.select { |x| x =~ /individual.verification/ }.any?
      end

      def stripe_account
        @stripe_account ||=
          External::StripeApi::Account.retrieve(@current_organisation.stripe_account_id_live)
      end

      def stripe_account_requirements
        @stripe_account_requirements ||= stripe_account.requirements.currently_due
      end

      def stripe_connect_hosted_onboarding_path
        External::StripeApi::AccountLink.
          create(@current_organisation.stripe_account_id_live,
                 failure_url: guides_welcome_stripe_account_link_failure_url,
                 success_url: new_guides_welcome_bank_account_url,
                 type: "account_onboarding")
      end

      def stripe_external_account
        @stripe_external_account ||=
          External::StripeApi::ExternalAccount.create(@current_organisation.stripe_account_id_live,
                                                      params[:token_account])
      end
    end
  end
end
