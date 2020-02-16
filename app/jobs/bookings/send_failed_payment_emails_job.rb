module Bookings
  class SendFailedPaymentEmailsJob
    include Sidekiq::Worker

    def perform(booking_id, payment_failure_message = "General card error")
      booking = Booking.find(booking_id)

      Guests::FailedPaymentMailer.
        with(booking: booking, payment_failure_message: payment_failure_message).
        new.deliver_later
      Guides::FailedPaymentMailer.
        with(booking: booking, payment_failure_message: payment_failure_message).
        new.deliver_later
    end
  end
end
