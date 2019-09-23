module Guides
  module Welcome
    # Handles the creation of new directors/owners
    class CompanyPeopleController < ApplicationController
      layout "onboarding"
      before_action :authenticate_guide!
      before_action :set_current_organisation

      # TODO: could do with an onboarding object... that determines what to show based on
      # current state of the @current_organisation ?
      # Or use the StripeAccount object, and save each raw_response... and status in there...?
      def new; end

      def create
        create_new_company_people

        if create_another_company_person?
          redirect_to new_guides_welcome_company_person_path
        else
          redirect_to new_guides_welcome_bank_account_path
        end
      end

      private

      def create_another_company_person?
        params[:add_another_company_person].present?
      end

      def create_new_company_people
        # TODO: create / capture raw_stripe_api_response
        # How to actually record a new company_people has been created in the app?
        # Save the person token... and then retreive that from Stripe when we
        # need to show the company_peoples' data?
        External::StripeApi::Person.create(@current_organisation.stripe_account_id,
                                           company_people_params.to_h,
                                           @current_organisation&.on_trial?)
      end

      def company_people_params
        # TODO: replace these with a person token.
        # https://stripe.com/docs/connect/account-tokens#form
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
