module OrganisationDecorator
  def currency
    self[:currency] || "gbp"
  end

  def stripe_publishable_key
    on_trial? ? ENV.fetch("STRIPE_PUBLISHABLE_KEY_TEST") : ENV.fetch("STRIPE_PUBLISHABLE_KEY_LIVE")
  end

  def stripe_publishable_key_live
    ENV.fetch("STRIPE_PUBLISHABLE_KEY_LIVE")
  end

  def subdomain_or_www
    return "" if Settings.env_staging?

    self[:subdomain] || "www"
  end
end
