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

  def show_onboarding_explainer_element?(trip, count)
    # ie: if first trip has no bookings.
    @current_organisation.on_trial? && trip.bookings.count.zero? && count.zero?
  end

  def show_in_trial_banner?
    @current_organisation&.on_trial? &&
      @current_organisation.bookings.exists? &&
      @current_organisation.bookings.most_recent.last.created_at < 3.minutes.ago
  end
end
