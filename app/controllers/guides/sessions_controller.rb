class Guides::SessionsController < Devise::SessionsController

  def new
    super
    flash.delete(:notice)
  end

  # POST /resource/sign_in
  def create
    super
    flash.delete(:notice)
  end

  # DELETE /resource/sign_out
  def destroy
    super
    flash.delete(:notice)
  end
end
