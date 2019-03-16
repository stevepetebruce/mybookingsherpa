module Guides
  class TripsController < ApplicationController
    before_action :authenticate_guide!

    def index
      @trips = current_guide.trips.start_date_desc.map do |trip|
        TripDecorator.new(trip)
      end
    end
  end
end
