class Guides::RegistrationsController < Devise::RegistrationsController
  layout "minimal"

  def create
    super
    create_organisation_and_subscription
    flash.delete(:notice)
  end

  protected

  def after_sign_up_path_for(_resource)
    authenticated_guide_path
  end

  def create_organisation_and_subscription
    if resource.persisted?
      # TODO: be more clever about how we select the default currency here... Could use: https://github.com/hexorx/countries
      # organisation = Organisation.create(currency: "eur", ...

      # TODO: wrap this in a transaction and rescue ActiveRecord::InvalidRecord exception
      organisation = Organisation.create
      OrganisationMembership.create(organisation: organisation, guide: resource, owner: true)
      Subscription.create(organisation: organisation, plan: discount_plan)
      Onboarding.create(organisation: organisation)
      Onboardings::OnboardingInitialisationJob.perform_later(organisation, request.remote_ip)
    end
  end

  # TODO: will need to manually move these guides onto the default (name: "regular")
  #   plan 6 months after they sign up
  def discount_plan
    Plan.find_by_name("discount (0.5%)")
  end
end
