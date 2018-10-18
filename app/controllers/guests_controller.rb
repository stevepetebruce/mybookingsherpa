class GuestsController < ApplicationController
  before_action :set_guest, only: [:show, :edit, :update, :destroy]

  # GET /guests
  def index
    # TODO: scope this to an organisation
    @guests = Guest.all
  end

  # GET /guests/1
  def show
  end

  # GET /guests/new
  def new
    @guest = Guest.new
  end

  # GET /guests/1/edit
  def edit
  end

  # POST /guests
  # TODO: This is overridden by Devise::RegistrationsController#create
  # def create
  #   @guest = Guest.new(guest_params)

  #   if @guest.save
  #     redirect_to @guest, notice: 'Guest was successfully created.'
  #   else
  #     render :new
  #   end
  # end

  # PATCH/PUT /guests/1
  def update
    if @guest.update(guest_params)
      redirect_to @guest, notice: 'Guest was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /guests/1
  def destroy
    #TODO: what do we want to happen here? Just remove a guest from an organisation?
    # Destroy organisation_guest join?
    @guest.destroy
    redirect_to guests_url, notice: 'Guest was successfully destroyed.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_guest
    # TODO: scope this to an organisation
    @guest = Guest.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def guest_params
    params.require(:guest).permit(:address,
                                  :email,
                                  :name,
                                  :phone_number)
  end
end
