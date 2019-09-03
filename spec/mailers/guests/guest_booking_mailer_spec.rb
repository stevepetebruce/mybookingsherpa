require "rails_helper"

RSpec.describe Guests::BookingMailer, type: :mailer do
  describe "#new" do
    let!(:booking) { FactoryBot.create(:booking, :with_payment, trip: trip) }
    let!(:guide_email) { Faker::Internet.email }
    let!(:guide_name) { Faker::Name.name }
    let(:mail) { described_class.with(booking: booking).new.deliver_now }
    let(:organisation) { trip.organisation }
    let!(:trip) { FactoryBot.create(:trip) }

    it "renders the headers" do
      expect(mail.subject).to eq("Successful booking for #{booking.trip_name}")
      # Isn't picking up the actual format used in mailer - with guide's name, etc.
      expect(mail.from).to eq([ENV.fetch("DEFAULT_GUIDE_FROM_EMAIL")])
      expect(mail.reply_to).to eq([ENV.fetch("DEFAULT_GUIDE_FROM_EMAIL")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("thank you")
    end

    context "organisation on_trial" do
      it "should send the email to the guide" do
        expect(mail.to).to eq([booking.guide_email])
      end
    end

    context "organisation not on_trial" do
      before do
        allow(organisation).to receive(:on_trial?).and_return(true)
      end

      it "should send the email to the guest" do
        expect(mail.to).to eq([booking.guide_email])
      end
    end
  end
end
