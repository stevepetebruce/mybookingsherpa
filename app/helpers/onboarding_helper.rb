module OnboardingHelper
  def element_to_hide(trip, count)
    return "pointer-three" if show_first_trial_booking_explaner_element?(trip, count)
    "pointer-one"
  end

  def in_trial_and_created_booking?
    @current_organisation&.on_trial? &&
      @current_organisation.bookings.exists?
  end

  def in_trial_and_created_an_hour_ago?
    @current_organisation&.on_trial? && @current_organisation.created_at < 1.hour.ago
  end

  def open_first_trip_accordion?(count)
    @current_organisation.on_trial? &&
      @current_organisation.trips.count == 1 &&
      count == 0
  end

  def show_first_trial_booking_explaner_element?(trip, count)
    @current_organisation.on_trial? &&
      count.zero? && # this is the first trip
      trip.bookings.count == 1 && # they've created a trial booking
      trip.bookings.most_recent.last.created_at > 24.hours.ago # within the last 24 hours
  end

  def show_in_trial_banner?
    return false if @hide_in_trial_banner

    in_trial_and_created_an_hour_ago? || in_trial_and_created_booking?
  end

  def show_onboarding_explainer_element?(trip, count)
    # ie: if first trip has no bookings.
    @current_organisation.on_trial? && trip.bookings.count.zero? && count.zero?
  end

  def stripe_account_link(type="custom_account_verification")
    External::StripeApi::AccountLink.
      create(@current_organisation.stripe_account_id,
             failure_url: guides_welcome_stripe_account_link_failure_url,
             success_url: new_guides_welcome_bank_account_url,
             type: type)
  end

  def trial_example_country
    @example_data.value(:country_select)
  end

  def trial_example_dob_or_nil(booking)
    booking.organisation_on_trial? ? @example_data.value(:dob) : nil
  end

  def trial_example_email_or_nil(booking)
    booking.organisation_on_trial? ? @example_data.value(:email) : nil
  end

  def trial_example_full_name_or_nil(booking)
    booking.organisation_on_trial? ? @example_data.value(:full_name) : nil
  end

  def trial_example_ice_name_or_nil(booking)
    booking.organisation_on_trial? ? @example_data.value(:ice_name) : nil
  end

  def trial_example_ice_phone_or_nil(booking)
    booking.organisation_on_trial? ? @example_data.value(:ice_phone) : nil
  end

  def trial_example_phone_or_nil(booking)
    booking.organisation_on_trial? ? @example_data.value(:phone) : nil
  end
end
