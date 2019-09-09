module OnboardingHelper

  def element_to_hide(trip, count)
    return "pointer-three" if show_first_trial_booking_explaner_element?(trip, count)
    "pointer-one"
  end

  def in_trial_and_created_booking?
    @current_organisation&.on_trial? &&
      @current_organisation.bookings.exists? &&
      @current_organisation.bookings.most_recent.last.created_at < 2.minutes.ago
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
end
