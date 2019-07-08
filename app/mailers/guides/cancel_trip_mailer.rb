module Guides
  # Sent to guide when there isn't enough guests on trip and she needs to confirm
  # she wants to cancel
  class CancelTripMailer < ApplicationMailer
    def new
      @trip = params[:trip]
      @guide = @trip.guide

      mail(to: @guide.email,
           from: "#{ENV.fetch('SUPPORT_EMAIL_NAME')} <#{ENV.fetch('SUPPORT_EMAIL_ADDRESS')}>",
           reply_to: "#{ENV.fetch('SUPPORT_EMAIL_NAME')} <#{ENV.fetch('SUPPORT_EMAIL_ADDRESS')}>",
           subject: "Cancel #{@trip.name} #{trip_start_date_formatted} ?",
           template_path: "mailers/guides",
           template_name: "cancel_trip")
    end

    private

    def trip_start_date_formatted
      "#{@trip.start_date.day} #{Date::MONTHNAMES[@trip.end_date.month]}"
    end
  end
end
