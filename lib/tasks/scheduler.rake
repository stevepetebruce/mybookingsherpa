desc "Checks if a trip is now within the period of the full payment window"
task take_full_payment_or_refund_deposits: :environment do
  puts "Runnning take_full_payment_or_refund_deposits task"

  puts "Trip.future_trips.count #{Trip.future_trips.count}"

  Trip.future_trips.find_each do |trip|
    puts "Current future trip id #{trip.id} - #{trip.name}"
    puts "trip.organisation_on_trial? #{trip.organisation_on_trial?}"

    Trips::OutstandingPaymentDueJob.perform_later(trip) unless trip.organisation_on_trial?
  end

  puts "Finished runnning take_full_payment_or_refund_deposits task"
end
