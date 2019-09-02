require "rails_helper"

RSpec.describe Onboardings::Factory, type: :model do
  describe "#create" do
    subject(:create) { described_class.create(organisation) }
    let(:organisation) { FactoryBot.create(:organisation) }

    context "valid and successful" do
      it "should create a new onboarding object associated with the organisation" do
        create

        expect(organisation.reload.onboarding).to_not be_nil
      end
    end
  end
end
