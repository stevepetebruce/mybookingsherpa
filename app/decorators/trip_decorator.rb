# Presentation layer related methods for Trip model.
module TripDecorator
  def new_public_booking_link
    if organisation.on_trial?
      on_trial_new_public_booking_link
    else
      live_new_public_booking_link
    end
  end

  def live_new_public_booking_link
    "#{base_domain_and_subdomain}#{paths.new_public_trip_booking_path(slug)}"
  end

  private

  def base_domain
    base_domain_array.last
  end

  def base_domain_and_subdomain
    "#{http_or_https}//#{subdomain}#{base_domain}"
  end

  def base_domain_array
    @base_domain_array ||= ENV.fetch("PUBLIC_BOOKING_DOMAIN")&.split("//")
  end

  def http_or_https
    base_domain_array.first
  end

  def in_trial_new_booking_link_warning_post_fix
    "DO_NOT_SHARE_IN_TRIAL_EXAMPLE_PLEASE_COMPLETE_YOUR_ACCOUNT_SET_UP"
  end

  def on_trial_new_public_booking_link
    "#{live_new_public_booking_link}?#{in_trial_new_booking_link_warning_post_fix}"
  end

  def paths
    Rails.application.routes.url_helpers
  end

  def subdomain
    return "#{organisation_subdomain_or_www}."
  end
end
