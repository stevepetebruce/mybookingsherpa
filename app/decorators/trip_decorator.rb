class TripDecorator < SimpleDelegator
  def initialize(trip)
    @trip = trip
    super
  end

  def new_public_booking_link
    # TODO: add organisation's subdomain
    "#{ENV.fetch('BASE_DOMAIN')}#{paths.new_public_trip_booking_path(@trip.slug)}"
  end

  private

  def paths
    Rails.application.routes.url_helpers
  end
end
