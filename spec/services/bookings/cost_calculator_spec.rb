require "rails_helper"
# 4 possible states:

# 1) Deposit due
# True, when: before full window period, deposit percentage has been set,

# 2) Full payment due
# True when: no deposit % has been set
# True when: deposit % has been set but after full payment period

# 3) Final payment due
# True when: deposit has been paid, past full payment window

# 4) Nothing due just yet
# True when: deposit has been paid, before full payment window

RSpec.describe Bookings::CostCalculator, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let!(:booking) { FactoryBot.create(:booking, trip: trip) }
  let!(:trip) do
    FactoryBot.create(:trip,
                      currency: :gbp,
                      deposit_percentage: deposit_percentage,
                      end_date: 11.weeks.from_now,
                      full_cost: Faker::Number.between(from: 5_000_0, to: 10_000_0),
                      full_payment_window_weeks: full_payment_window_weeks,
                      start_date: 8.weeks.from_now)
  end

  describe "#amount_due" do
    subject(:amount_due) { described_class.new(booking).amount_due }

    describe "deposit due" do
      context "deposit_percentage has been set" do
        let!(:deposit_percentage) { Faker::Number.between(from: 10, to: 50) }

        context "before full payment window (in weeks) has elapsed" do
          let(:full_payment_window_weeks) { 4 }

          it "should be the deposit cost" do
            travel 3.weeks do
              expect(amount_due).to eq(trip.deposit_cost)
            end
          end
        end
      end
    end

    describe "full cost due" do
      let!(:deposit_percentage) { Faker::Number.between(from: 10, to: 50) }
      let(:full_payment_window_weeks) { 4 }

      context "after full payment window (in weeks) has elapsed" do
        it "should be the full cost" do
          travel_to(trip.start_date - 1.week) do
            expect(amount_due).to eq(trip.full_cost)
          end
        end
      end
    end

    describe "final payment due" do
      context "deposit has been paid" do
        let!(:deposit_payment) do
          FactoryBot.create(:payment,
                            :success,
                            amount: trip.deposit_cost,
                            booking: booking)
        end

        let!(:deposit_percentage) { Faker::Number.between(from: 10, to: 50) }
        let(:full_payment_window_weeks) { 4 }

        context "after full payment window (in weeks) has elapsed" do
          it "should be the remaining amount due" do
            travel_to(trip.start_date - 1.week) do
              expect(amount_due).to eq(trip.full_cost - trip.deposit_cost)
            end
          end
        end
      end
    end

    context "no payment due just yet" do
      context "deposit has been paid" do
        let!(:deposit_payment) do
          FactoryBot.create(:payment,
                            :success,
                            amount: trip.deposit_cost,
                            booking: booking)
        end

        let!(:deposit_percentage) { Faker::Number.between(from: 10, to: 50) }
        let(:full_payment_window_weeks) { 4 }

        context "before full payment window (in weeks) has elapsed" do
          it "should be the remaining amount due" do
            travel_to(trip.start_date - 5.weeks) do
              expect(amount_due).to eq(0)
            end
          end
        end
      end
    end

    # Test misc states
    context "deposit_percentage is 0" do
      let(:deposit_percentage) { 0 }
      let(:full_payment_window_weeks) { 4 }

      it "should be the full trip cost" do
        expect(amount_due).to eq(trip.full_cost)
      end
    end
  end

  describe "#deposit_paid?" do
    subject(:deposit_paid?) { described_class.deposit_paid?(booking) }

    let!(:deposit_percentage) { Faker::Number.between(from: 10, to: 50) }
    let(:full_payment_window_weeks) { 4 }

    context "deposit has been paid" do
      let!(:deposit_payment) do
        FactoryBot.create(:payment,
                          :success,
                          amount: trip.deposit_cost,
                          booking: booking)
      end

      it "should be true" do
        expect(deposit_paid?).to eq true
      end
    end

    context "deposit has not been paid" do
      it "should be true" do
        expect(deposit_paid?).to eq false
      end
    end
  end
end
