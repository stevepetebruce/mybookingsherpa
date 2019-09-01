require "rails_helper"

RSpec.describe Onboardings::FactoryJob, type: :job do
  before { ActiveJob::Base.queue_adapter = :inline }

  describe "#perform_later" do
    subject(:perform_later) { described_class.perform_later(organisation) }

    let!(:organisation) { FactoryBot.create(:organisation) }

    context "valid and successful" do
      it "should create a new onboarding object associated with the organisation" do
        perform_later

        expect(organisation.reload.onboarding).to_not be_nil
      end
    end
  end
end
