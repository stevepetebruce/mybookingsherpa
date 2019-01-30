class GuestsController < ApplicationController
  before_action :set_guest, only: %i[show edit update]
  before_action :authenticate_guest!

  def edit; end

  def show; end

  # TODO: This is overridden by Devise::RegistrationsController#create
  # But we actually want to override that behaviour... we want to only create
  # a guest when a new booking clicks on the link in their email.
  # def create
  # end

  def update
    if @guest.update(guest_params)
      redirect_to @guest, notice: 'Guest was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_guest
    @guest = current_guest
  end

  def guest_params
    params.require(:guest).permit(:address,
                                  # TODO: we want to email new & old emails to let them know of change
                                  :email,
                                  :name,
                                  :phone_number)
  end
end
