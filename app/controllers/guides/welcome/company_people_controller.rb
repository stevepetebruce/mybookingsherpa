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
        create_new_company_person # TODO: need to surface any errors from Stripe API

        if add_another_company_person?
          redirect_to new_guides_welcome_company_person_path
        else
          redirect_to new_guides_welcome_bank_account_path
        end
      end

      private

      def add_another_company_person?
        params[:add_another_company_person] == "true"
      end

      def create_new_company_person
        CompanyPeople::Factory.create(company_person_params[:first_name],
                                      company_person_params[:last_name],
                                      @current_organisation,
                                      stripe_person.id)
      end

      def stripe_person
        # TODO: create / capture raw_stripe_api_response
        External::StripeApi::Person.create(@current_organisation.stripe_account_id,
                                           company_person_params[:token_person],
                                           @current_organisation&.on_trial?)
      end

      def company_person_params
        params.permit(:first_name, :last_name, :token_person)
      end

      def set_current_organisation
        # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
        @current_organisation ||= current_guide.organisation_memberships.owners.first.organisation
      end
    end
  end
end
