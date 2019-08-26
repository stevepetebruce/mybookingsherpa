# frozen_string_literal: true

module Guides
  module Welcome
    # The onboarding controller for solo founder guides
    class SolosController < ApplicationController
      layout "onboarding"
      before_action :authenticate_guide!
      before_action :set_current_organisation

      # TODO: could do with an onboarding object... that determines what to show based on
      # current state of the @current_organisation ?
      # Or use the StripeAccount object, and save each raw_response... and status in there...?
      def new; end

      def create
        if create_stripe_account
          redirect_to new_guides_welcome_bank_account_path
        else
          flash.now[:alert] = "Problem creating account. #{error_message}"
          render :new
        end
      end

      private

      def create_stripe_account
        # TODO: create / capture raw_stripe_api_response
        # TODO: move this to a background job? - and reveal to Guide any errors in my account view...?
        # Would then need another way (other than checking @current_organisation has stripe_account_id - in conditional "creating_stripe_account?" )
        @current_organisation.update(stripe_account_id: stripe_account.id)
      rescue Stripe::InvalidRequestError => e
        @stripe_error_message = e.message
        false
      end

      def error_message
        return @stripe_error_message if defined?(@stripe_error_message)

        @current_organisation.errors.full_messages.to_sentence
      end

      def set_current_organisation
        # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
        @current_organisation ||= current_guide.organisation_memberships.owners.first.organisation
      end

      def stripe_account
        @stripe_account ||= External::StripeApi::Account.create(params[:token_account])
      end
    end
  end
end
