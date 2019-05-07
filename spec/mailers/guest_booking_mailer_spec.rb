require "rails_helper"

RSpec.describe GuestBookingMailer, type: :mailer do
  describe "#new" do
    let!(:booking) { FactoryBot.create(:booking, trip: trip, guest: guest) }
    let!(:guest) { FactoryBot.create(:guest) }
    let!(:guide) { FactoryBot.create(:guide, email: guide_email, name: guide_name) }
    let!(:guide_email) { Faker::Internet.email }
    let!(:guide_name) { Faker::Name.name }
    let(:mail) { described_class.with(booking: booking).new.deliver_now }
    let(:organisation) { FactoryBot.create(:organisation) }
    let!(:organisation_membership) do
      FactoryBot.create(:organisation_membership,
                        guide: guide,
                        organisation: organisation,
                        owner: true)
    end
    let!(:trip) { FactoryBot.create(:trip, guides: [guide]) }

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
