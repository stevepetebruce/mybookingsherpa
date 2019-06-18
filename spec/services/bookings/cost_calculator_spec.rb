require "rails_helper"
include ActiveSupport::Testing::TimeHelpers

RSpec.describe Bookings::CostCalculator, type: :model do
  let!(:booking) { FactoryBot.create(:booking, trip: trip) }
  let!(:trip) do 
    FactoryBot.create(:trip,
                      currency: :gbp,
                      deposit_percentage: deposit_percentage,
                      end_date: 11.weeks.from_now,
                      full_cost: rand(5_000_0...10_000_0),
                      full_payment_window_weeks: full_payment_window_weeks,
                      start_date: 10.weeks.from_now)
  end

  describe "#amount_due" do
    subject(:amount_due) { described_class.new(booking).amount_due }

    context "before full payment window (in weeks) has elapsed" do
      let!(:deposit_percentage) { rand(10...50) }
      let(:full_payment_window_weeks) { 4 }

      it "should be the deposit cost" do
        travel 4.weeks do
          expect(amount_due).to eq(trip.deposit_cost)
        end
      end
    end

    context "after full payment window (in weeks) has elapsed" do
      let!(:deposit_percentage) { rand(10...50) }
      let(:full_payment_window_weeks) { 4 }

      it "should be the full trip cost" do
        travel 7.weeks do
          expect(amount_due).to eq(trip.full_cost)
        end
      end
    end

    context "trip has no full payment window set" do
      let!(:deposit_percentage) { rand(10...50) }
      let(:full_payment_window_weeks) { nil }

      it "should be the full trip cost" do
        expect(amount_due).to eq(trip.full_cost)
      end
    end

    context "deposit_percentage is nil" do
      let(:deposit_percentage) { nil }
      let(:full_payment_window_weeks) { 4 }

      it "should be the full trip cost" do
        expect(amount_due).to eq(trip.full_cost)
      end
    end

    context "deposit_percentage is 0" do
      let(:deposit_percentage) { 0 }
      let(:full_payment_window_weeks) { 4 }

      it "should be the full trip cost" do
        expect(amount_due).to eq(trip.full_cost)
      end
    end
  end
end
