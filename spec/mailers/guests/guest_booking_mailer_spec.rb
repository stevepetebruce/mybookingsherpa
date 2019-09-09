require "rails_helper"

RSpec.describe Guests::BookingMailer, type: :mailer do
  describe "#new" do
    let!(:booking) { FactoryBot.create(:booking, :with_payment, trip: trip) }
    let!(:guide_email) { Faker::Internet.email }
    let!(:guide_name) { Faker::Name.name }
    let(:mail) { described_class.with(booking: booking).new.deliver_now }
    let!(:onboarding) { FactoryBot.create(:onboarding, organisation: organisation) }
    let!(:organisation) { booking.organisation }
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

      it "should have the trial explainer text" do
        expect(mail.body.encoded).to include("As you're in trial")
      end
    end

    context "organisation not on_trial" do
      before { onboarding.update_columns(complete: true) }

      it "should send the email to the guest" do
        expect(mail.to).to eq([booking.email])
      end

      it "should not have the trial explainer text" do
        expect(mail.body.encoded).to_not include("As you're in trial")
      end
    end
  end
end
