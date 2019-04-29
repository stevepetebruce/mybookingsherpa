module Guides
  class TripsController < ApplicationController
    before_action :authenticate_guide!
    before_action :set_show_past_trips

    def index
      if @show_past_trips
        @trips = current_guide.trips.past_trips.map do |trip|
          TripDecorator.new(trip)
        end
      else
        @trips = current_guide.trips.future_trips.map do |trip|
          TripDecorator.new(trip)
        end
      end
    end

    private

    def set_show_past_trips
      @show_past_trips = params[:past_trips].presence == "true" ? true : false
    end
  end
end
