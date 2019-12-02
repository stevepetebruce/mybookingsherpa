require "rails_helper"

RSpec.describe Trips::OutstandingPaymentDueJob, type: :job do
  before { ActiveJob::Base.queue_adapter = :inline }

  describe "#perform_later" do
    subject(:perform_later) { described_class.perform_later(trip) }

    let!(:booking) { FactoryBot.create(:booking, trip: trip) }
    let(:trip) { FactoryBot.create(:trip) }

    before do
      stub_request(:post, "https://api.stripe.com/v1/charges").
        to_return(status: 200,
                  body: "#{file_fixture("stripe_api/successful_charge.json").read}",
                  headers: {})
    end

    context "trip whose full_payment_date is not today" do
      before do
        allow_any_instance_of(Trip).
          to receive(:full_payment_date).
          and_return(2.weeks.from_now)
      end

      it "should not call any other jobs" do
        expect(Trips::CancelTripEmailJob).to_not receive(:perform_later)
        expect(Bookings::PayOutstandingTripCostJob).to_not receive(:perform_async)

        perform_later
      end
    end

    context "trip whose full_payment_date has elapsed" do
      before do
        allow_any_instance_of(Trip).
          to receive(:full_payment_date).
          and_return(date_approx_one_week_ago)
      end

      let(:date_approx_one_week_ago) { rand(1.week).seconds.ago }

      context "that has_minimum_number_of_guests" do
        before do
          allow_any_instance_of(Trip).
            to receive(:has_minimum_number_of_guests?).
            and_return(true)
        end

        it "should only call Bookings::PayOutstandingTripCostJob" do
          expect(Bookings::PayOutstandingTripCostJob).to receive(:perform_async)
          expect(Trips::CancelTripEmailJob).to_not receive(:perform_later)

          perform_later
        end
      end

      context "that has_minimum_number_of_guests is not true" do
        before do
          allow_any_instance_of(Trip).
            to receive(:has_minimum_number_of_guests?).
            and_return(false)
        end

        it "should only call Trips::CancelTripEmailJob" do
          expect(Trips::CancelTripEmailJob).to receive(:perform_later)
          expect(Bookings::PayOutstandingTripCostJob).to_not receive(:perform_async)

          perform_later
        end
      end
    end

    context "trip that as no full_payment_date" do
      it "should not run any other jobs" do
        expect(Trips::CancelTripEmailJob).to_not receive(:perform_later)
        expect(Bookings::PayOutstandingTripCostJob).to_not receive(:perform_async)

        perform_later
      end
    end
  end
end
