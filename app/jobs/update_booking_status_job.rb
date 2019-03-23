class UpdateBookingStatusJob < ApplicationJob
  queue_as :default

  def perform(booking)
    Bookings::Status.new(booking).update
  end
end
