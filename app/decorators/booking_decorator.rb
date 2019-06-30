class BookingDecorator < SimpleDelegator
  def initialize(booking)
    @booking = booking
    super
  end

  def flag_icon
    return "flag-icon-#{@booking.guest_country&.downcase}" if @booking.guest_country.present?
    "flag-icon-#{@booking.country&.downcase}" if @booking.country.present?
  end

  def full_payment_date
    (@booking.trip_start_date - @booking.trip_full_payment_window_weeks.weeks).
      strftime("%F")
  end

  def gravatar_url(size = 36)
    "#{gravatar_base_url}/#{gravatar_id}.png?"\
      "s=#{size}&d=#{CGI.escape(gravatar_fallback_image_url)}"
  end

  def human_readable_amount_due
    "#{Currency.iso_to_symbol(@booking.currency)}" \
      "#{Currency.human_readable(Bookings::Payment.amount_due(@booking))}"
  end

  def human_readable_full_cost
    "#{Currency.iso_to_symbol(@booking.currency)}" \
      "#{Currency.human_readable(@booking.full_cost)}"
  end

  def only_paying_deposit?
    Bookings::Payment.amount_due(@booking) == @booking.deposit_cost
  end

  def payment_status_icon
    return "dot-danger" if @booking.red?
    return "dot-warning" if @booking.yellow?

    "dot-success"
  end

  def payment_status_text
    return "Last payment failed" if @booking.red?
    return "Payment required" if @booking.yellow?

    "Fully paid"
  end

  def stripe_publishable_key
    organisation_on_trial? ? ENV.fetch("STRIPE_PUBLISHABLE_KEY_TEST") : ENV.fetch("STRIPE_PUBLISHABLE_KEY_LIVE")
  end

  # Dynamically create fallback methods for name, address, etc.
  # For when guest has not confirmed email but guide still wants some info
  # So will be referenced: booking.name // = booking.guest.name || booking.name
  Guest::UPDATABLE_FIELDS.each do |field|
    define_method(field) { @booking&.guest&.send(field).presence || @booking.send(field) }
  end

  private

  def gravatar_base_url
    "https://gravatar.com/avatar"
  end

  def gravatar_fallback_image_url
    "https://img.icons8.com/windows/512/f7fafc/contacts.png"
  end

  def gravatar_id
    Digest::MD5.hexdigest(@booking.guest_email).downcase
  end
end
