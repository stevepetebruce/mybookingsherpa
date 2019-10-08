# frozen_string_literal: true
module Guides
  module Welcome
    # The onboarding controller for both solo and company based guides
    class BaseController < ApplicationController
      protected

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

      def stripe_account
        # TODO: create / capture raw_stripe_api_response
        # TODO: move this to a background job? - and reveal to Guide any errors in my account view...?
        # Would then need another way (other than checking @current_organisation has stripe_account_id - in conditional "creating_stripe_account?" )
        @stripe_account ||= External::StripeApi::Account.create_live_account_from_token(params[:token_account])
      end

      def set_current_organisation
        # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
        @current_organisation ||= current_guide.organisation_memberships.owners.first.organisation
      end
    end
  end
end
