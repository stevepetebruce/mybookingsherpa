# Presentation layer related methods for Trip model.
module TripDecorator
  def new_public_booking_link
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

  def paths
    Rails.application.routes.url_helpers
  end

  def subdomain
    return "#{organisation_subdomain}." if organisation_subdomain
  end
end
