module OrganisationDecorator
  def stripe_publishable_key
    on_trial? ? ENV.fetch("STRIPE_PUBLISHABLE_KEY_TEST") : ENV.fetch("STRIPE_PUBLISHABLE_KEY_LIVE")
  end
end
