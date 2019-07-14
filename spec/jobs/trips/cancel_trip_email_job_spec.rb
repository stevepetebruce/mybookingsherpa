require "rails_helper"

RSpec.describe Trips::CancelTripEmailJob, type: :job do
  include ActiveJob::TestHelper

  before { ActiveJob::Base.queue_adapter = :async }

  describe "#perform_later" do
    subject(:perform_later) { described_class.perform_later(trip) }

    let(:trip) { FactoryBot.create(:trip) }

    context "valid and successful" do
      it "should enque the Guide and Support CancelTripMailer emails" do
        perform_enqueued_jobs do
          expect { perform_later }.to change { ActionMailer::Base.deliveries.count }.by(2)
        end
      end
    end
  end
end
