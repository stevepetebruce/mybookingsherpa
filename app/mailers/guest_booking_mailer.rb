# Handles all emails sent to guests regarding their booking
class GuestBookingMailer < ApplicationMailer
  def new
    @booking = params[:booking]

    mail(to: @booking.email,
         from: "#{@booking.guide_name} <#{@booking.guide_email}>",
         reply_to: "#{@booking.guide_name} <#{@booking.guide_email}>",
         subject: "Successful booking for #{@booking.trip_name}")
  end
end
# TODO: Later we may bring the emailing in-house and reply-to our email system.
# Where guests and guides can track all their email conversations in one place.
