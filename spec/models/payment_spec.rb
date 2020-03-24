require "rails_helper"

RSpec.describe Payment, type: :model do
  it { should define_enum_for(:status).with_values(%i[pending success failed refunded]) }

  describe "associations" do
    it { should belong_to(:booking).optional(true) }
  end

  describe "callbacks" do
    let!(:payment) { FactoryBot.build(:payment) }

    it "should call #update_booking_payment_status" do
      expect(payment).to receive(:update_booking_payment_status)

      payment.save
    end
  end

  describe "validations" do
    context "stripe_payment_intent_id" do
      it { should validate_uniqueness_of(:stripe_payment_intent_id).ignoring_case_sensitivity }
    end
  end

  describe "#failed?" do
    subject(:failed?) { payment.failed? }

    context "when there's no failure_code in the raw_response" do
      let!(:payment) { FactoryBot.build(:payment) }

      it "should be false" do
        expect(failed?).to eq(false)
      end
    end

    context "when there's is a failure_code in the raw_response" do
      let!(:payment) { FactoryBot.build(:payment, :failed) }

      it "should be true" do 
        expect(failed?).to eq(true)
      end
    end
  end

  describe "#failure_message" do
    subject(:failure_message) { payment.failure_message }

    context "when there's no failure_message in the raw_response" do
      let!(:payment) { FactoryBot.build(:payment) }

      it "should be nil/empty" do 
        expect(failure_message).to be_nil
      end
    end

    context "when there's is a failure_message in the raw_response" do
      let!(:payment) { FactoryBot.build(:payment, :failed) }

      it "should not be nil/empty" do 
        expect(failure_message).to_not be_nil
      end
    end
  end
end
