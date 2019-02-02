class ApplicationController < ActionController::Base
  def after_sign_in_path_for(resource)
    if resource.instance_of? Guide
      guides_trips_path
    elsif resource.instance_of? Guest
      guests_trips_path
    end
  end

  def after_sign_out_path_for(resource)
    if resource == :guide
      new_guide_session_path
    elsif resource == :guest
      new_guest_session_path
    end
  end
end
