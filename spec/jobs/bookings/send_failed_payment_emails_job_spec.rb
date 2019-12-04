require "rails_helper"

RSpec.describe Bookings::SendFailedPaymentEmailsJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.perform_in(15.minutes, stripe_payment_intent_id, payment_failure_message) }

    let!(:payment) { FactoryBot.create(:payment, :failed, stripe_payment_intent_id: stripe_payment_intent_id) }
    let(:payment_failure_message) { "Your card was declined. This transaction requires authentication." }
    let!(:stripe_payment_intent_id) { "cus_#{Faker::Crypto.md5}" }

    context "valid and successful" do
      it "should send the guide and guest emails" do
        expect { perform }.to change { ActionMailer::Base.deliveries.count }.by(2)
      end
    end
  end
end
