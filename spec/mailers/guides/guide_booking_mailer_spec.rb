require "rails_helper"

RSpec.describe Guides::BookingMailer, type: :mailer do
  describe "#new" do
    let!(:booking) { FactoryBot.create(:booking, :with_payment, trip: trip) }
    let!(:guide) { FactoryBot.create(:guide, email: guide_email, name: guide_name) }
    let!(:guide_email) { Faker::Internet.email }
    let!(:guide_name) { Faker::Name.name }
    let(:mail) { described_class.with(booking: booking).new.deliver_now }
    let!(:onboarding) { FactoryBot.create(:onboarding, organisation: organisation) }
    let(:organisation) { booking.organisation }
    let!(:trip) { FactoryBot.create(:trip, guides: [guide]) }

    it "renders the headers" do
      expect(mail.subject).to eq("New booking for #{booking.trip_name} #{booking.start_date.day} #{Date::MONTHNAMES[booking.end_date.month]}")
      expect(mail.to).to eq([guide.email])
      expect(mail.from).to eq([ENV.fetch("SUPPORT_EMAIL_ADDRESS")])
      expect(mail.reply_to).to eq([ENV.fetch("SUPPORT_EMAIL_ADDRESS")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Thank you")
    end

    context "on trial" do
      it "should have the trial explainer text" do
        expect(mail.body.encoded).to include("As you're in trial")
      end
    end

    context "not on trial" do
      before { onboarding.update_columns(complete: true) }

      it "should not have the trial explainer text" do
        expect(mail.body.encoded).to_not include("As you're in trial")
      end
    end
  end
end
