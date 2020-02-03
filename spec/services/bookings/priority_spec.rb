require "rails_helper"

# NB:
# 0: No action required from the guide.
# 1: Guest has other information.
# 2: Booking has incomplete data which is still required.
# 3: Payment required.

RSpec.describe Bookings::Priority, type: :model do
  describe "#new_priority" do
    subject(:new_priority) { described_class.new(booking).new_priority }

    context "a booking that has made full payment, with no other information and no missing required data" do
      let(:booking) { FactoryBot.create(:booking, :complete_without_any_issues) }
      let!(:payment) { FactoryBot.create(:payment, :success, amount: booking.full_cost, booking: booking) }

      it "should have a priority value of 0" do
        expect(new_priority).to eq 0
      end
    end

    context "a booking that has made full payment, with allergies and no missing required data" do
      let(:booking) { FactoryBot.create(:booking, :complete_with_allergies) }
      let!(:payment) { FactoryBot.create(:payment, :success, amount: booking.full_cost, booking: booking) }

      it "should have a priority value of 0" do
        expect(new_priority).to eq 1
      end
    end

    context "a booking that has made full payment, with dietary_requirements and no missing required data" do
      let(:booking) { FactoryBot.create(:booking, :complete_with_dietary_requirements) }
      let!(:payment) { FactoryBot.create(:payment, :success, amount: booking.full_cost, booking: booking) }

      it "should have a priority value of 0" do
        expect(new_priority).to eq 1
      end
    end

    context "a booking that has made full payment, with other information and no missing required data" do
      let(:booking) { FactoryBot.create(:booking, :complete_with_other_information) }
      let!(:payment) { FactoryBot.create(:payment, :success, amount: booking.full_cost, booking: booking) }

      it "should have a priority value of 0" do
        expect(new_priority).to eq 1
      end
    end

    context "a booking that has made full payment, with no other information but with missing required data" do
      let(:booking) { FactoryBot.create(:booking, :basic_fields_complete) }
      let!(:payment) { FactoryBot.create(:payment, :success, amount: booking.full_cost, booking: booking) }

      it "should have a priority value of 0" do
        expect(new_priority).to eq 2
      end
    end

    context "a booking that has not made full payment" do
      let(:booking) { FactoryBot.create(:booking, :basic_fields_complete) }
      let!(:payment) { FactoryBot.create(:payment, :success, amount: (booking.full_cost / 2), booking: booking) }

      it "should have a priority value of 0" do
        expect(new_priority).to eq 3
      end
    end
  end
end
