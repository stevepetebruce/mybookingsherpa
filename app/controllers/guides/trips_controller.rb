module Guides
  class TripsController < ApplicationController
    before_action :authenticate_guide!
    before_action :set_trip, only: [:show, :edit, :update] # TODO: destroy - see note below

    def index
      @trips = current_guide.trips.start_date_desc.map { |trip| TripDecorator.new(trip) }
    end

    def show
    end

    def new
      @trip = current_guide.trips.new
    end

    def edit
    end

    def create
      @trip = current_guide.trips.new(trip_params.merge(organisation: current_organisation))

      if @trip.save
        redirect_to guides_trip_path(@trip), notice: 'Trip was successfully created.'
      else
        render :new
      end
    end

    def update
      if @trip.update(trip_params)
        redirect_to guides_trip_path(@trip), notice: 'Trip was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /trips/1
    # TODO: who has authority to do this?
    # TODO: soft delete?
    # def destroy
    #   @trip.destroy
    #   redirect_to trips_url, notice: 'Trip was successfully destroyed.'
    # end

    private
    
    def current_organisation
      # TODO: make this more nuanced - a guide would set what organisation they are looking
      # at when they are logged in... Need to pass around the organisation_id, by nesting
      # all guide routes within an organisation resource
      current_guide.organisations.first
    end

    def set_trip
      @trip = current_guide.trips.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def trip_params
      params.require(:trip).permit(:name,
                                   :start_date,
                                   :end_date,
                                   :deposit_cost,
                                   :full_cost,
                                   :minimum_number_of_guests,
                                   :maximum_number_of_guests)
    end
  end
end
