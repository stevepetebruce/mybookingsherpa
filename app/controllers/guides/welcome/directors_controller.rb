module Guides
  module Welcome
    class DirectorsController < ApplicationController
      before_action :authenticate_guide!
      before_action :set_current_organisation

      # TODO: could do with an onboarding object... that determines what to show based on
      # current state of the @current_organisation ?
      # Or use the StripeAccount object, and save each raw_response... and status in there...?
      def new; end

      def create
        create_new_director

        if create_another_director?
          redirect_to new_guides_welcome_director_path
        else
          redirect_to guides_trips_path
        end
      end

      private

      def create_another_director?
        params[:add_another_director].present?
      end

      def create_new_director
        # TODO: create / capture raw_stripe_api_response
        External::StripeApi::Person.create(@current_organisation.stripe_account_id, director_params.to_h)
      end

      def director_params
        params.permit(:email, :first_name, :gender, :last_name, :phone,
                      address: [:line1, :line2, :city, :state, :postal_code, :country],
                      dob: [:day, :month, :year],
                      relationship: [:director, :owner, :percent_ownership, :title])
      end

      def set_current_organisation
        # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
        @current_organisation ||= current_guide.organisation_memberships.owners.first.organisation
      end
    end
  end
end
