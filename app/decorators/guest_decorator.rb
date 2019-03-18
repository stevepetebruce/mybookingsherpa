class GuestDecorator < SimpleDelegator
  def initialize(guest)
    @guest = guest
    super
  end

  def flag_icon
    # TODO: extract flag icon from guest data... ie: country they entered
    ["flag-icon-fr", "flag-icon-gb", "flag-icon-us"].sample
  end

  def gravatar_url(size = 36)
    "#{gravatar_base_url}/#{gravatar_id}.png?"\
      "s=#{size}&d=#{CGI.escape(gravatar_fallback_image_url)}"
  end

  def status(trip)
    return "dot-warning" if @guest.bookings.where(trip_id: trip.id).first.yellow?

    "dot-success"
  end

  # Dynamically create fallback methods for name, address, etc.
  # For when guest has not confirmed email but guide still wants some info
  Guest::UPDATABLE_FIELDS.each do |field|
    define_method(field) { @guest.send(field).presence || @guest.most_recent_booking.send(field) }
  end

  private

  def gravatar_base_url
    "http://gravatar.com/avatar"
  end

  def gravatar_fallback_image_url
    "https://www.gravatar.com/avatar/?d=mp&s=200"
  end

  def gravatar_id
    Digest::MD5.hexdigest(@guest.email).downcase
  end
end
