require "rails_helper"

RSpec.describe Guests::BookingMailer, type: :mailer do
  describe "#new" do
    let!(:booking) { FactoryBot.create(:booking, trip: trip) }
    let!(:guide_email) { Faker::Internet.email }
    let!(:guide_name) { Faker::Name.name }
    let(:mail) { described_class.with(booking: booking).new.deliver_now }
    let!(:trip) { FactoryBot.create(:trip) }

    it "renders the headers" do
      expect(mail.subject).to eq("Successful booking for #{booking.trip_name}")
      expect(mail.to).to eq([booking.email])
      # Isn't picking up the actual format used in mailer - with guide's name, etc.
      expect(mail.from).to eq([ENV.fetch("DEFAULT_GUIDE_FROM_EMAIL")])
      expect(mail.reply_to).to eq([ENV.fetch("DEFAULT_GUIDE_FROM_EMAIL")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("thank you")
    end
  end
end
