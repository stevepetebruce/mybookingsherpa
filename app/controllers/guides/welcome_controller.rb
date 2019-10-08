module Guides
  # Onboarding controller before Guides split into solo or company onboarding.
  class WelcomeController < ApplicationController
    layout "onboarding"
    before_action :authenticate_guide!
    before_action :set_current_organisation

    def new
      @hosted_onboarding_url ||= hosted_onboarding_url
    end

    private

    def create_hosted_onboarding_url
      Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY_TEST")
      Stripe::AccountLink.create({
        account: @current_organisation.stripe_account_id,
        failure_url: guides_welcome_url,
        success_url: guides_welcome_url,
        type: "custom_account_verification"
      }).url
    end

    def set_current_organisation
      # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
      # TODO: move this to a base controller / concern?
      @current_organisation ||= current_guide&.organisation_memberships&.owners&.first&.organisation
    end

    def hosted_onboarding_url
      @hosted_onboarding_url ||= create_hosted_onboarding_url
    end
  end
end
