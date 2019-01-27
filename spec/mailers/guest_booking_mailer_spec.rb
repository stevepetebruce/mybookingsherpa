require "rails_helper"

RSpec.describe GuestBookingMailer, type: :mailer do
  describe "#new" do
    let(:booking) { FactoryBot.create(:booking) }
    let(:mail) do 
      described_class.with(booking: booking).new.deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Successful booking for #{booking.trip_name}")
      expect(mail.to).to eq([booking.email])
      expect(mail.from).to eq(["bookings@bookyour.place"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("thank you")
    end
  end
end
