module Bookings
  class UpdatePaymentStatusJob < ApplicationJob
    queue_as :default

    def perform(booking)
      Bookings::PaymentStatus.new(booking).update
    end
  end
end
