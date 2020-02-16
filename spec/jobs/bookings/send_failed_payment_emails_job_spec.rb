require "rails_helper"

RSpec.describe Bookings::SendFailedPaymentEmailsJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.perform_in(15.minutes, booking.id, payment_failure_message) }

    let(:booking) { payment.booking }
    let!(:payment) { FactoryBot.create(:payment, :failed) }
    let(:payment_failure_message) { "Your card was declined. This transaction requires authentication." }

    context "valid and successful" do
      it "should send the guide and guest emails" do
        expect { perform }.to change { ActionMailer::Base.deliveries.count }.by(2)
      end
    end
  end
end
