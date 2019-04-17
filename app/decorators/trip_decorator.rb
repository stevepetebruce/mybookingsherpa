class TripDecorator < SimpleDelegator
  def initialize(trip)
    @trip = trip
    super
  end

  def new_public_booking_link
    "#{base_domain_and_subdomain}#{paths.new_public_trip_booking_path(@trip)}"
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
    return "#{@trip.organisation_subdomain}." if @trip.organisation_subdomain
  end
end
