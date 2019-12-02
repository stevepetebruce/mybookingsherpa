require "rails_helper"

RSpec.describe Bookings::SendNewBookingEmailsJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.perform_in(15.minutes, stripe_payment_intent_id) }

    let!(:booking) { FactoryBot.create(:booking) }
    let(:deposit_amount) { booking.full_cost * 0.10 }
    let(:outstanding_amount) { booking.full_cost * 0.90 }
    let!(:stripe_payment_intent_id) { "cus_#{Faker::Crypto.md5}" }


    context "booking that is not paying outstanding amount (ie, this is deposit or full payment)" do
      before do 
        FactoryBot.create(:payment,
                          amount: [booking.full_cost, deposit_amount].sample,
                          booking: booking,
                          stripe_payment_intent_id: stripe_payment_intent_id)
      end

      it "should send the guide and guest emails" do
        expect { perform }.to change { ActionMailer::Base.deliveries.count }.by(2)
      end
    end

    context "booking that is paying outstanding amount" do
      before do 
        FactoryBot.create(:payment,
                          amount: deposit_amount,
                          booking: booking,
                          stripe_payment_intent_id: stripe_payment_intent_id)
        FactoryBot.create(:payment,
                          amount: outstanding_amount,
                          booking: booking,
                          stripe_payment_intent_id: stripe_payment_intent_id)
      end

      it "should not send the guide and guest emails" do
        expect { perform }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end
  end
end
