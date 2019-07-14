module Trips
  # Called when there's not enough guests on trip.
  class CancelTripEmailJob < ApplicationJob
    queue_as :default

    def perform(trip)
      Support::CancelTripMailer.with(trip: trip).new.deliver_later(wait: 3.days)
      Guides::CancelTripMailer.with(trip: trip).new.deliver_later
    end
  end
end
