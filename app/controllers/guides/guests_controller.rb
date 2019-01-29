module Guides
  class GuestsController < ApplicationController
    before_action :authenticate_guide!

    def index
      @guests = current_guide.guests
    end

    def show
      @guest = current_guide.guests.find(params[:id])
    end
  end
end
