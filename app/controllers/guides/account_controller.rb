module Guides
  class AccountController < ApplicationController
    before_action :authenticate_guide!
    before_action :set_current_organisation

    def create
      puts 'params ' + params.inspect
      @account = Account.new(account_params)
      # TODO: ? current_organisation.accounts.create(account_params)
      if @account.save!
        # flash[:success] = "Account created" #? need to think about the UX
        redirect_to guides_welcome_path
      else
        # flash.now[:alert] = # ? need to think about the UX may need to present Stripe API errors on posting form page
        redirect_to guides_welcome_path
      end
    end

    def update
    end

    private

    def account_params
    end

    def set_current_organisation
      # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
      @current_organisation ||= current_guide.organisation_memberships.owners.first.organisation
    end
  end
end
# Processing by Guides::AccountController#create as HTML
# 11:55:11 AM web.1   |
# Parameters: {
# "token-account"=>"ct_1F3hMoESypPNvvdYLqQxVY02",
# "token-person"=>"cpt_1F3hMoESypPNvvdYKp7RbtYE",
# "company_name"=>"",
# "street_address1"=>"",
# "city"=>"", "state"=>"", "zip"=>"", "first_name"=>"", "last_name"=>""}

