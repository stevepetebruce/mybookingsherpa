class GuestsController < ApplicationController
  # TODO: reinstate when we have guests who can log in
  # OBFUSCATED_ONE_TIME_LOGIN_TOKEN_PARAM_NAME = "esuyp"
  # before_action :set_guest, only: %i[show edit update]
  # before_action :authenticate_guest_or_one_time_token!

  # def edit; end

  # def show; end

  # def update
  #   if @guest.update(guest_params)
  #     redirect_to @guest, flash: { success: "Guest was successfully updated." }
  #   else
  #     render :edit, alert: "Problem creating guest. #{@guest.errors.full_messages.to_sentence}"
  #   end
  # end

  # private

  # def authenticate_guest_or_one_time_token!
  #   if one_time_login_token.present?
  #     one_time_login_process
  #   else
  #     authenticate_guest!
  #   end
  # end

  # def invalidate_one_time_login_token(guest)
  #   guest.update(one_time_login_token: SecureRandom.hex(16))
  # end

  # def guest_params
  #   params.require(:guest).permit(:address_override,
  #                                 :name_override,
  #                                 :phone_number_override)
  # end
  
  # def one_time_login_process
  #   @guest = Guest.where(one_time_login_token: one_time_login_token,
  #                        email: params[:email]).first

  #   invalidate_one_time_login_token(@guest)
  #   Guests::BookingUpdater.new(@guest).copy_booking_values
  #   sign_in(@guest)
  # end

  # def one_time_login_token
  #   params[OBFUSCATED_ONE_TIME_LOGIN_TOKEN_PARAM_NAME]
  # end

  # def set_guest
  #   @guest = current_guest
  # end
end
