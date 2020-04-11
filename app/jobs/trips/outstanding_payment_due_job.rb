module Trips
  # For trips whose full_payment_date has passed, collects full payments
  # for all guests OR emails guide cancel trip email, if not enough guests
  class OutstandingPaymentDueJob < ApplicationJob
    queue_as :default

    def perform(trip)
      puts "OutstandingPaymentDueJob for #{trip.id} #{trip.name}"
      puts "trip.full_payment_date.nil?  #{trip.id}  #{trip.full_payment_date.nil?}"
      puts "trip.full_payment_date > Time.zone.now  #{trip.id}  #{trip.full_payment_date > Time.zone.now}" if trip.full_payment_date

      return if trip.full_payment_date.nil? ||
                trip.full_payment_date > Time.zone.now

      if trip.has_minimum_number_of_guests?
        puts "trip.has_minimum_number_of_guests #{trip.id} #{trip.name}"
        collect_outstanding_payment(trip)
      else
        puts "! trip.has_minimum_number_of_guests - CancelTripEmailJob #{trip.id} #{trip.name}"
        Trips::CancelTripEmailJob.perform_later(trip)
      end
    end

    private

    def collect_outstanding_payment(trip)
      trip.bookings.each do |booking|
        puts "collect_outstanding_payment booking: #{booking.id}"
        puts "outstanding_payment_required?(booking) booking: #{booking.id} #{outstanding_payment_required?(booking)}"

        next unless outstanding_payment_required?(booking)

        Bookings::PayOutstandingTripCostJob.perform_async(booking.id)
      end
    end

    def outstanding_payment_required?(booking)
      Bookings::PaymentStatus.new(booking).payment_required?
    end
  end
end
