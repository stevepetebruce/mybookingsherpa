require "rails_helper"

RSpec.describe Guides::CancelTripMailer, type: :mailer do
  describe "#new" do
    let(:guide) { trip.guide }
    let(:mail) { described_class.with(trip: trip).new.deliver_now }
    let!(:trip) { FactoryBot.create(:trip) }

    it "renders the headers" do
      expect(mail.subject).to include("Cancel")
      expect(mail.to).to eq([guide.email])
      expect(mail.from).to eq([ENV.fetch("SUPPORT_EMAIL_ADDRESS")])
      expect(mail.reply_to).to eq([ENV.fetch("SUPPORT_EMAIL_ADDRESS")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Thank you")
    end
  end
end
