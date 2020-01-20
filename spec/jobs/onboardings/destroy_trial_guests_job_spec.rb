require "rails_helper"

RSpec.describe Onboardings::DestroyTrialGuestsJob, type: :job do
  before { ActiveJob::Base.queue_adapter = :inline }

  describe "#perform_later" do
    subject(:perform_later) { described_class.perform_later(organisation) }
    let!(:onboarding) {FactoryBot.create(:onboarding, organisation: organisation) }
    let!(:organisation) { FactoryBot.create(:organisation) }
    let!(:trip) { FactoryBot.create(:trip, organisation: organisation) }

    context "valid and successful" do
      let!(:booking_created_in_trial) do
        FactoryBot.create(:booking,
                          organisation: organisation,
                          trip: trip,
                          guest: guest_created_in_trial,
                          created_at: 10.days.ago)
      end
      let!(:guest_created_in_trial) { FactoryBot.create(:guest) }

      context "organisation who has completed onboarding" do
        let!(:booking_created_after_trial) do
          FactoryBot.create(:booking,
                            organisation: organisation,
                            trip: trip,
                            guest: guest_created_after_trial,
                            created_at: 10.days.from_now)
        end
        let!(:guest_created_after_trial) { FactoryBot.create(:guest, created_at: 10.days.from_now) }

        before do
          onboarding.track_event("trial_ended")
          onboarding.update_columns(complete: true)
        end

        it "should destroy the guests and bookings created whilst in trial" do
          perform_later

          expect(organisation.guests).not_to include(guest_created_in_trial)
          expect(organisation.bookings).not_to include(booking_created_in_trial)
        end

        it "should not destroy the guests and bookings created after trial" do
          perform_later

          expect(organisation.guests).to include(guest_created_after_trial)
          expect(organisation.bookings).to include(booking_created_after_trial)
        end
      end

      context "organisation who has not completed onboarding" do
        it "should not destroy any guests or bookings" do
          perform_later

          expect(organisation.guests).to include(guest_created_in_trial)
          expect(organisation.bookings).to include(booking_created_in_trial)
        end
      end
    end
  end
end
