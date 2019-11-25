module Guides
  # Sends guide notification that a payment has failed
  class FailedPaymentMailer < ApplicationMailer
    def new
      @booking = params[:booking]
      @guide = @booking.guide
      @payment_failure_message = params[:payment_failure_message]

      mail(to: @booking.guide_email,
           from: "#{ENV.fetch('SUPPORT_EMAIL_NAME')} <#{ENV.fetch('SUPPORT_EMAIL_ADDRESS')}>",
           reply_to: "#{ENV.fetch('SUPPORT_EMAIL_NAME')} <#{ENV.fetch('SUPPORT_EMAIL_ADDRESS')}>",
           subject: "❗️Outstanding Payment Failed for #{@booking.email} booked on #{@booking.trip_name} #{trip_start_date_formatted}",
           template_path: "mailers/guides",
           template_name: "failed_payment")
    end

    private

    def trip_start_date_formatted
      "#{@booking.start_date.day} #{Date::MONTHNAMES[@booking.start_date.month]}"
    end
  end
end
