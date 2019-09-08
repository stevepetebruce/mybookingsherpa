module ApplicationHelper
  def bootstrap_class_for flash_type
    { success: "alert-success", alert: "alert-danger", notice: "alert-info" }.stringify_keys[flash_type.to_s] || flash_type.to_s
  end

  def flash_messages
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)}", role: "alert") do 
              concat content_tag(:button, "x", class: "close", data: { dismiss: "alert" })
              concat message 
            end)
    end
    nil
  end

  def show_first_trial_booking_explaner_element?(trip, count)
    @current_organisation.on_trial? &&
      count.zero? && # this is the first trip
      trip.bookings.count == 1 && # they've created a trial booking
      trip.bookings.most_recent.last.created_at > 24.hours.ago # within the last 24 hours
  end

  def show_onboarding_explainer_element?(trip, count)
    # ie: if first trip has no bookings.
    @current_organisation.on_trial? && trip.bookings.count.zero? && count == 0
  end
end
