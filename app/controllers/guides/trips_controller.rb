module Guides
  class TripsController < ApplicationController
    before_action :authenticate_guide!
    before_action :set_current_organisation, only: %i[create edit index new]
    before_action :set_trip, only: %i[edit update]
    before_action :set_show_past_trips, only: %i[index]

    def create
      @trip = @current_organisation.trips.new(trip_params)

      if @trip.save && current_guide.trips << @trip
        redirect_to guides_trips_path, flash: { success: "Trip created" }
      else
        flash.now[:alert] = "Problem creating trip. #{@trip.errors.full_messages.to_sentence}"
        render :new
      end
    end

    def edit; end

    def index
      @trips = if @show_past_trips
                 current_guide.trips.past_trips
               else
                 current_guide.trips.future_trips
               end
    end

    def new
      @trip = @current_organisation
              .trips
              .new(deposit_percentage: @current_organisation.deposit_percentage,
                   full_payment_window_weeks: @current_organisation.full_payment_window_weeks)
    end

    def update
      if @trip.update(trip_params)
        redirect_to guides_trips_path, flash: { success: "Trip updated" }
      else
        flash.now[:alert] = "Problem creating trip. #{@trip.errors.full_messages.to_sentence}"
        render :edit
      end
    end

    private

    def set_current_organisation
      # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
      @current_organisation ||= current_guide.organisation_memberships.owners.first.organisation
    end

    def set_trip
      @trip = current_guide.trips.find(params[:id])
    end

    def set_show_past_trips
      @show_past_trips = params[:past_trips].presence == "true" ? true : false
    end

    def trip_params
      params.require(:trip).permit(:currency,
                                   :description,
                                   :deposit_percentage,
                                   :full_cost,
                                   :full_payment_window_weeks,
                                   :name,
                                   :start_date,
                                   :end_date,
                                   :minimum_number_of_guests,
                                   :maximum_number_of_guests)
    end
  end
end
