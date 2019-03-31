class BookingDecorator < SimpleDelegator
  def initialize(booking)
    @booking = booking
    super
  end

  def flag_icon
    return "flag-icon-#{@booking.guest_country&.downcase}" if @booking.guest_country.present?
    "flag-icon-#{@booking.country&.downcase}" if @booking.country.present?
  end

  def gravatar_url(size = 36)
    "#{gravatar_base_url}/#{gravatar_id}.png?"\
      "s=#{size}&d=#{CGI.escape(gravatar_fallback_image_url)}"
  end

  def status(trip)
    return "dot-warning" if @booking.yellow?

    "dot-success"
  end

  def status_alert?
    status_text.present?
  end

  def status_text
    # TODO: what if there's more than one label? Guide would want to see Medical condition and dietary requirements
    return "Incomplete booking details" if Bookings::Status.new(@booking).personal_details_incomplete?
    return "Payment required" if Bookings::Status.new(@booking).payment_required?
    return "Medical conditions" if Bookings::Status.new(@booking).medical_conditions?
    return "Allergies" if Bookings::Status.new(@booking).allergies?
    return "Dietary requirements" if Bookings::Status.new(@booking).dietary_requirements?
  end

  # Dynamically create fallback methods for name, address, etc.
  # For when guest has not confirmed email but guide still wants some info
  # So will be referenced: booking.name // = booking.guest.name || booking.name
  Guest::UPDATABLE_FIELDS.each do |field|
    define_method(field) { @booking.guest.send(field).presence || @booking.send(field) }
  end

  private

  def gravatar_base_url
    "http://gravatar.com/avatar"
  end

  def gravatar_fallback_image_url
    "https://img.icons8.com/windows/512/f7fafc/contacts.png"
  end

  def gravatar_id
    Digest::MD5.hexdigest(@booking.guest_email).downcase
  end
end
