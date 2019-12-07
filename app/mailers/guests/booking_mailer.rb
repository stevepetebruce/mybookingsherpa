module Guests
  # Handles all emails sent to guests regarding their booking
  class BookingMailer < ApplicationMailer
    def new
      @booking = params[:booking]

      mail(to: email_target,
           from: "#{@booking.guide_name} <#{ENV.fetch('DEFAULT_GUIDE_FROM_EMAIL')}>",
           reply_to: "#{@booking.guide_name} <#{ENV.fetch('DEFAULT_GUIDE_FROM_EMAIL')}>",
           subject: "You're booked on #{@booking.trip_name}",
           template_path: "mailers/guests",
           template_name: "new")
    end

    private

    def email_target
      @booking.organisation_on_trial? ? @booking.guide.email : @booking.email
    end
  end
end
# TODO: Later we may bring the emailing in-house and reply-to our email system.
# Where guests and guides can track all their email conversations in one place.
