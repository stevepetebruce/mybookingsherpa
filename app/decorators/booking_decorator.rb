# Presentation layer related methods for Booking model.
module BookingDecorator
  # Dynamically create fallback methods for name, address, etc.
  # For when guest has not confirmed email but guide still wants some info
  # So will be referenced: booking.guest_or_booking_name // = booking.guest.name || booking.name
  Guest::UPDATABLE_FIELDS.each do |field|
    define_method("guest_or_booking_#{field}") { guest&.send(field).presence || send(field) }
  end

  def amount_due
    Bookings::CostCalculator.amount_due(self)
  end

  def flag_icon
    "flag-icon-#{guest_or_booking_country.downcase}" if guest_or_booking_country.present?
  end

  def gravatar_url(size = 36)
    "#{gravatar_base_url}/#{gravatar_id}.png?" \
      "s=#{size}&d=#{CGI.escape(gravatar_fallback_image_url)}"
  end

  def guest_or_booking_allergies
    guest.allergies.presence || allergies
  end

  def guest_or_booking_allergies?
    guest_or_booking_allergies.exists?
  end

  def guest_or_booking_dietary_requirements
    guest.dietary_requirements.presence || dietary_requirements
  end

  def guest_or_booking_dietary_requirements?
    guest_or_booking_dietary_requirements.exists?
  end

  def human_readable_allergies
    guest_or_booking_allergies&.pluck(:name)&.map(&:capitalize).to_sentence
  end

  def human_readable_amount_due
    "#{Currency.iso_to_symbol(currency)}" \
      "#{Currency.human_readable(amount_due)}"
  end

  def human_readable_dietary_requirements
    guest_or_booking_dietary_requirements&.pluck(:name)&.map(&:capitalize).to_sentence
  end

  def human_readable_failed_amount_due
    "#{Currency.iso_to_symbol(currency)}" \
      "#{Currency.human_readable(last_failed_payment.amount)}"
  end

  def human_readable_full_cost
    "#{Currency.iso_to_symbol(currency)}" \
      "#{Currency.human_readable(full_cost)}"
  end

  def human_readable_full_cost_minus_deposit
    return "" unless deposit_cost

    "#{Currency.iso_to_symbol(currency)}" \
      "#{Currency.human_readable(full_cost - deposit_cost)}"
  end

  def human_readable_full_payment_date
    full_payment_date&.strftime("%d-%m-%Y") || ""
  end

  def only_paying_deposit?
    amount_due == deposit_cost
  end

  def payment_status_icon
    return "dot-danger" if payment_failed?
    return "dot-danger" if refunded?
    return "dot-warning" if payment_required?

    "dot-success"
  end

  def payment_status_text
    return "Last payment failed" if payment_failed?
    return "Payment required" if payment_required?
    return "Refunded" if refunded?

    "Fully paid"
  end

  def stripe_publishable_key
    organisation_on_trial? ? ENV.fetch("STRIPE_PUBLISHABLE_KEY_TEST") : ENV.fetch("STRIPE_PUBLISHABLE_KEY_LIVE")
  end

  private

  def gravatar_base_url
    "https://gravatar.com/avatar"
  end

  def gravatar_fallback_image_url
    "https://img.icons8.com/windows/512/f7fafc/contacts.png"
  end

  def gravatar_id
    Digest::MD5.hexdigest(guest_email).downcase
  end
end
