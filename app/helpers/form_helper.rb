module FormHelper
  # Utility module for making forms that little bit better
  def auto_focus(model, form_field:, default_auto_focus: false)
    return true if default_auto_focus && model.errors.empty?
    return true if form_field == model.errors.details.keys.first

    false
  end
end
