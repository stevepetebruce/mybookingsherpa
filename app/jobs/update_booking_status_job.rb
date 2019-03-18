class UpdateBookingStatusJob < ApplicationJob
  queue_as :default

  def perform(booking)
    Bookings::StatusUpdater.new(booking).update
  end
end
