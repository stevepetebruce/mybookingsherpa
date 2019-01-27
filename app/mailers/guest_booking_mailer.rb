# Handles all emails sent to guests regarding their booking
class GuestBookingMailer < ApplicationMailer
  def new
    @booking = params[:booking]

    mail(to: @booking.email,
         # TODO: from: "#{@booking.guide_name} <#{@booking.owner_email}>",
         # TODO: reply_to: "#{@booking.owner_name} <#{@booking.owner_email}>"
         subject: "Successful booking for #{@booking.trip_name}")
  end
end
# TODO: Later we may bring the emailing in-house and reply-to our email system.
# Where guests and guides can track all their email conversations in one place.
