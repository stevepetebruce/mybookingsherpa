module Bookings
  # ref: https://stripe.com/docs/payments/cards/charging-saved-cards#create-payment-intent-off-session
  class PayOutstandingTripCostJob
    include Sidekiq::Worker
    sidekiq_options queue: :default, retry: 0

    MINIMUM_APPLICATION_FEE = 200 # £/€/$2

    def perform(booking_id)
      puts "PayOutstandingTripCostJob booking_id: #{booking_id}"

      @booking = Booking.find(booking_id)

      puts "full_payment_required? #{full_payment_required?}"
      # TODO: look at this... this job fails when in trial: return if @booking.organisation_on_trial?
      return unless full_payment_required?

      payment = @booking.payments.create(status: :pending,
                                         stripe_payment_intent_id: payment_intent.id)

      puts "payment created. #{payment.inspect}"
    end

    private

    def full_payment_required?
      # TODO: check this... once we create the payment - even if it the payment_intent fails
      #  this will return false, when it totals up all the payments' amounts associated with
      #  this booking...
      Bookings::PaymentStatus.new(@booking).payment_required?
    end

    def payment_intent
      @payment_intent ||= Bookings::PaymentIntents.create(@booking)
    end
  end
end
