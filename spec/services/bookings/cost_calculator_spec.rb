require "rails_helper"

RSpec.describe Bookings::CostCalculator, type: :model do
  let(:booking) { FactoryBot.create(:booking, trip: trip) }
  let(:trip) { FactoryBot.create(:trip, currency: :gbp, full_cost: 500) }

  describe "#amount_due" do
    subject(:amount_due) { described_class.new(booking).amount_due }

    context "valid and successful" do
      it { should eq 500 }
    end
  end

  describe "#amount_due_in_cents" do
    subject(:amount_due_in_cents) do
      described_class.new(booking).amount_due_in_cents
    end

    context "valid and successful" do
      it { should eq 50_000 }
    end
  end
end
