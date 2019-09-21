module OnboardingHelper
  def element_to_hide(trip, count)
    return "pointer-three" if show_first_trial_booking_explaner_element?(trip, count)
    "pointer-one"
  end

  def in_gb?
    @current_organisation.country_code == "gb"
  end

  def in_trial_and_created_booking?
    @current_organisation&.on_trial? &&
      @current_organisation.bookings.exists? &&
      @current_organisation.bookings.most_recent.last.created_at < 1.minutes.ago
  end

  def in_trial_and_created_over_a_day_ago?
    @current_organisation&.on_trial? && @current_organisation.created_at < 1.day.ago
  end

  def show_first_trial_booking_explaner_element?(trip, count)
    @current_organisation.on_trial? &&
      count.zero? && # this is the first trip
      trip.bookings.count == 1 && # they've created a trial booking
      trip.bookings.most_recent.last.created_at > 24.hours.ago # within the last 24 hours
  end

  def show_in_trial_banner?
    in_trial_and_created_over_a_day_ago? || in_trial_and_created_booking?
  end

  def show_onboarding_explainer_element?(trip, count)
    # ie: if first trip has no bookings.
    @current_organisation.on_trial? && trip.bookings.count.zero? && count.zero?
  end

  def trial_example_country
    @example_data.example_country_data(:country_select)
  end

  def trial_example_dob_or_nil(booking)
    booking.organisation_on_trial? ? @example_data.example_country_data(:dob) : nil
  end

  def trial_example_email_or_nil(booking)
    booking.organisation_on_trial? ? @example_data.example_country_data(:email) : nil
  end

  def trial_example_first_name
    @example_data.example_country_data(:full_name).split(" ").first
  end

  def trial_example_full_name_or_nil(booking)
    booking.organisation_on_trial? ? @example_data.example_country_data(:full_name) : nil
  end

  def trial_example_ice_name_or_nil(booking)
    booking.organisation_on_trial? ? @example_data.example_country_data(:ice_name) : nil
  end

  def trial_example_ice_phone_or_nil(booking)
    booking.organisation_on_trial? ? @example_data.example_country_data(:ice_phone) : nil
  end

  def trial_example_phone_or_nil(booking)
    booking.organisation_on_trial? ? @example_data.example_country_data(:phone) : nil
  end
end
