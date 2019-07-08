module Guides
  # Handles all emails sent to guides: new booking alerts, etc
  class BookingMailer < ApplicationMailer
    def new
      @booking = params[:booking]

      mail(to: @booking.guide_email,
           from: "#{ENV.fetch('SUPPORT_EMAIL_NAME')} <#{ENV.fetch('SUPPORT_EMAIL_ADDRESS')}>",
           reply_to: "#{ENV.fetch('SUPPORT_EMAIL_NAME')} <#{ENV.fetch('SUPPORT_EMAIL_ADDRESS')}>",
           subject: "New booking for #{@booking.trip_name} #{trip_start_date_formatted}",
           template_path: "mailers/guides",
           template_name: "new")
    end

    private

    def trip_start_date_formatted
      "#{@booking.start_date.day} #{Date::MONTHNAMES[@booking.end_date.month]}"
    end
  end
end
