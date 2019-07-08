module Guests
  # Handles all emails sent to guests regarding their booking
  class BookingMailer < ApplicationMailer
    def new
      @booking = params[:booking]

      mail(to: @booking.email,
           from: "#{@booking.guide_name} <#{ENV.fetch('DEFAULT_GUIDE_FROM_EMAIL')}>",
           reply_to: "#{@booking.guide_name} <#{ENV.fetch('DEFAULT_GUIDE_FROM_EMAIL')}>",
           subject: "Successful booking for #{@booking.trip_name}",
           template_path: "mailers/guests",
           template_name: "new")
    end
  end
end
# TODO: Later we may bring the emailing in-house and reply-to our email system.
# Where guests and guides can track all their email conversations in one place.
