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
        if creating_stripe_account?
          @current_organisation.update(stripe_account_id: raw_stripe_api_response.id)
          redirect_to new_guides_welcome_solo_path # need to expose any errors
        else
          create_bank_account
          redirect_to guides_trips_path
        end
      end

      private

      def create_bank_account
        # TODO: create / capture raw_stripe_api_response
        # Add a field to organisation - to record that bank account has been created...
        Stripe::Account.create_external_account(
          @current_organisation.stripe_account_id,
          {
            external_account: params[:token_account],
          }
        )
      end

      def creating_stripe_account?
        @current_organisation.stripe_account_id.blank?
      end

      def raw_stripe_api_response
        # TODO: create / capture raw_stripe_api_response
        @raw_stripe_api_response ||= External::StripeApi::Account.create(params[:token_account])
      end

      def set_current_organisation
        # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
        @current_organisation ||= current_guide.organisation_memberships.owners.first.organisation
      end
    end
  end
end
