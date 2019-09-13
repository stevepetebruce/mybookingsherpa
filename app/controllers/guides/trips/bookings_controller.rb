module Guides
  module Trips
    class BookingsController < ApplicationController
      before_action :authenticate_guide!
      before_action :set_current_organisation, only: %i[index]
      before_action :set_trip

      private

      def set_current_organisation
        # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
        # TODO: move this to a base controller / concern?
        @current_organisation ||= current_guide&.organisation_memberships&.owners&.first&.organisation
      end

      def set_trip
        @trip = current_guide.trips.find(params[:trip_id]) 
      end
    end
  end
end
