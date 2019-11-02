class Guides::RegistrationsController < Devise::RegistrationsController
  after_action :create_organisation, only: %i[create]

  layout "minimal"

  def create
    super
    flash.delete(:notice)
  end

  protected

  def after_sign_up_path_for(_resource)
    authenticated_guide_path
  end

  def create_organisation
    if resource.persisted?
      # TODO: be more clever about how we select the default currency here... Could use: https://github.com/hexorx/countries
      # organisation = Organisation.create(currency: "eur", ...

      organisation = Organisation.create
      OrganisationMembership.create(organisation: organisation, guide: resource, owner: true)
      Onboardings::OnboardingInitialisationJob.perform_later(organisation, request.remote_ip)
    end
  end
end
