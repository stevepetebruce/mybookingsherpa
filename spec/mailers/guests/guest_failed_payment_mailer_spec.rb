require "rails_helper"

RSpec.describe Guests::FailedPaymentMailer, type: :mailer do
  describe "#new" do
    let!(:booking) { FactoryBot.create(:booking, :with_failed_payment, trip: trip) }
    let(:mail) { described_class.with(booking: booking).new.deliver_now }
    let!(:organisation) { booking.organisation }
    let!(:trip) { FactoryBot.create(:trip) }

    it "renders the headers" do
      expect(mail.subject).to eq("❗️Your Outstanding Payment Failed for #{trip.name} "\
                                 "#{trip.start_date.strftime("%d %B")}")
      # Isn't picking up the actual format used in mailer - with guide's name, etc.
      expect(mail.from).to eq([ENV.fetch("DEFAULT_GUIDE_FROM_EMAIL")])
      expect(mail.reply_to).to eq([ENV.fetch("DEFAULT_GUIDE_FROM_EMAIL")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Your outstanding payment of") # has failed...
    end

    it "should send the email to the guest" do
      expect(mail.to).to eq([booking.email])
    end
  end
end
