module Trips
  # For trips whose full_payment_date has passed, collects full payments
  # for all guests OR emails guide cancel trip email, if not enough guests
  class OutstandingPaymentDueJob < ApplicationJob
    queue_as :default

    def perform(trip)
      return if trip.full_payment_date.nil? ||
                trip.full_payment_date > Time.zone.now

      if trip.has_minimum_number_of_guests?
        collect_outstanding_payment(trip)
      else
        Trips::CancelTripEmailJob.perform_later(trip)
      end
    end

    private

    def collect_outstanding_payment(trip)
      trip.bookings.each do |booking|
        next unless outstanding_payment_required?(booking)

        Bookings::PayOutstandingTripCostJob.perform_later(booking)
      end
    end

    def outstanding_payment_required?(booking)
      Bookings::PaymentStatus.new(booking).payment_required?
    end
  end
end
