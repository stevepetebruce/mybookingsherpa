module Guides
  class BookingsController < ApplicationController
    before_action :authenticate_guide!

    def show
      @booking = current_guide.bookings.find(params[:id])
    end
  end
end
