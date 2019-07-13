module Trips
  # Called when there's not enough guests on trip.
  class CancelTripEmailJob < ApplicationJob
    queue_as :default

    def perform(trip)
      # TODO: also send support an email in 3 days to let them know a trip may need to be refunded
      Guides::CancelTripMailer.with(trip: trip).new.deliver_later
    end
  end
end
