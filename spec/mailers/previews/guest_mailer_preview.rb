class GuestMailerPreview < ActionMailer::Preview
  def new
    GuestBookingMailer.with(booking: Booking.last).new
  end
end
