# frozen_string_literal: true
module Guides
  module Welcome
    # Handles failed Stripe Accounts Link requests
    # Ref: https://stripe.com/docs/api/account_links
    class StripeAccountLinkFailureController < ApplicationController
      before_action :authenticate_guide!
      before_action :set_current_organisation

      def new
        redirect_to new_hosted_onboarding_url
      end

      private

      def new_hosted_onboarding_url
        External::StripeApi::AccountLink.
          create(@current_organisation.stripe_account_id_live,
                 failure_url: guides_welcome_stripe_account_link_failure_url,
                 success_url: new_guides_welcome_bank_account_url)
      end

      def set_current_organisation
        # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
        @current_organisation ||= current_guide.organisation_memberships.owners.first.organisation
      end
    end
  end
end
