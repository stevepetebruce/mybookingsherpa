desc "Checks if a trip is now within the period of the full payment window"
task take_full_payment_or_refund_deposits: :environment do
  puts "Runnning take_full_payment_or_refund_deposits task"

  Trip.future_trips.find_each do |trip|
    Trips::OutstandingPaymentDueJob.perform_later(trip)
  end

  puts "Finished runnning take_full_payment_or_refund_deposits task"
end
