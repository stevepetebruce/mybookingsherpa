module Guides
  class TripsController < ApplicationController
    before_action :authenticate_guide!
    before_action :set_show_past_trips, only: %i[index]

    def create
      @trip = current_organisation.trips.new(trip_params)

      if @trip.save && current_guide.trips << @trip
        redirect_to edit_guides_trip_path(@trip)
      else
        render :new
      end
    end

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

    def new; end

    private

    def current_organisation
      # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
      current_guide.organisation_memberships.owners.first.organisation
    end

    def set_show_past_trips
      @show_past_trips = params[:past_trips].presence == "true" ? true : false
    end

    def trip_params
      params.require(:trip).permit(:full_cost,
                                   :name,
                                   :start_date,
                                   :end_date,
                                   :minimum_number_of_guests,
                                   :maximum_number_of_guests)
    end
  end
end
