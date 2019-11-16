module Guests
  # Sends guest notification that their payment has failed
  class FailedPaymentMailer < ApplicationMailer
    def new
      @booking = params[:booking]
      @payment_failure_message = params[:payment_failure_message]

      mail(to: @booking.email,
           from: "#{@booking.guide_name} <#{ENV.fetch('DEFAULT_GUIDE_FROM_EMAIL')}>",
           reply_to: "#{@booking.guide_name} <#{ENV.fetch('DEFAULT_GUIDE_FROM_EMAIL')}>",
           subject: "❗️Your Outstanding Payment Failed for #{@booking.trip_name} #{@booking.start_date.strftime("%d %B")}",
           template_path: "mailers/guests",
           template_name: "failed_payment")
    end
  end
end
