require "rails_helper"

RSpec.describe Trips::CancelTripEmailJob, type: :job do
  before { ActiveJob::Base.queue_adapter = :inline }

  describe "#perform_later" do
    subject(:perform_later) { described_class.perform_later(trip) }

    let(:trip) { FactoryBot.create(:trip) }

    context "valid and successful" do
      it "should enque the CancelTripMailer email" do
        # TODO: make this test more specific
        expect { perform_later }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end
