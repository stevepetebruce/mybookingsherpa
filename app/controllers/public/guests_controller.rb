module Public
  class GuestsController < ApplicationController
    TIMEOUT_WINDOW_MINUTES = 30
    skip_before_action :authenticate_guide! # / :authenticate_guest! ?
    before_action :set_guest_and_check_timeout, only: %i[edit update show]

    # GET /public/guests/:guest_id/edit
    def edit
    end

    # PATCH/PUT /public/guests/:guest_id
    def update
      if @guest.update(guest_params)
        redirect_to public_guest_path(@guest), notice: 'Guest was successfully updated.'
      else
        render :edit
      end
    end

    # GET /public/guests/:guest_id
    def show
    end

    private

    def set_guest_and_check_timeout
      set_guest
      check_timeout
    end

    def check_timeout
      return if newly_created?
      @guest.errors.add(:base, :timeout, message: 'timed out please contact support')
      # TODO: make fallback_location to the public/trip#show path when built in. Need to pass in trip id in hidden field
      redirect_back(fallback_location: root_path)
    end

    def newly_created?
      @guest.created_at > TIMEOUT_WINDOW_MINUTES.minutes.ago
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_guest
      # TODO: scope this to an organisation
      @guest = Guest.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def guest_params
      params.require(:guest).permit(:address,
                                    :email, # TODO: Do we want to allow guests to change their email via the public page
                                    :name,
                                    :phone_number)
    end
  end
end