module Guides
  class BookingsController < ApplicationController
    before_action :authenticate_guide!
    before_action :set_current_organisation

    def show
      @booking = current_guide.bookings.find(params[:id])
    end

    private

    def set_current_organisation
      # TODO: when a Guide owns more than one organisation, will need a way to choose btwn them.
      @current_organisation ||= current_guide&.organisation_memberships&.owners&.first&.organisation
    end
  end
end
