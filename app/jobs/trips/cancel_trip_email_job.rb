module Trips
  # Called when there's not enough guests on trip.
  class CancelTripEmailJob < ApplicationJob
    queue_as :default

    def perform(trip)
      # TODO: send email to guide confirming the cancellation of the trip.
      # Will include a reply to support@mybookingsherpa.com
      # Will then need to refund all bookings and email the guests.
    end
  end
end
