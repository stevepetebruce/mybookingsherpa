module Bookings
  class SendNewBookingEmailsJob
    include Sidekiq::Worker

    def perform(stripe_payment_intent_id)
      @stripe_payment_intent_id = stripe_payment_intent_id

      return if paying_outstanding_amount?

      Guests::BookingMailer.with(booking: booking).new.deliver_later
      Guides::BookingMailer.with(booking: booking).new.deliver_later
    end

    private

    def booking
      @booking ||= payment.booking
    end

    # Don't want to send (new booking) emails if paying outstanding amount
    def paying_outstanding_amount?
      booking.payments.count > 1
    end

    def payment
      @payment ||= Payment.find_by_stripe_payment_intent_id(@stripe_payment_intent_id)
    end
  end
end
