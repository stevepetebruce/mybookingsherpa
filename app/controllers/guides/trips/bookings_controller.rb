module Guides
  module Trips
    class BookingsController < ApplicationController
      before_action :authenticate_guide!
      before_action :set_trip

      private

      def set_trip
        @trip = current_guide.trips.find(params[:trip_id]) 
      end
    end
  end
end
