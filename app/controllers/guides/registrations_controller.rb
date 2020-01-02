class Guides::RegistrationsController < Devise::RegistrationsController
  after_action :create_organisation_and_subscription, only: %i[create]

  layout "minimal"

  def create
    super
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

      organisation = Organisation.create
      OrganisationMembership.create(organisation: organisation, guide: resource, owner: true)
      Onboardings::OnboardingInitialisationJob.perform_later(organisation, request.remote_ip)
      Subscription.create(organisation: organisation, plan: discount_plan)
    end
  end

  # TODO: will need to manually move these guides onto the default (name: "regular")
  #   plan 6 months after they sign up
  def discount_plan
    Plan.find_by_name("discount (0.5%)")
  end
end
