require "rails_helper"

RSpec.describe Onboarding, type: :model do
  describe "associations" do
    it { should belong_to(:organisation) }
  end

  describe "#track_event" do
    subject(:track_event) { onboarding.track_event(event, additional_info) }

    let(:onboarding) { FactoryBot.create(:onboarding) }

    context "an event without any additional_info" do
      let(:additional_info) { nil }
      let!(:event) { ["new_solo_account_chosen", "new_stripe_account_created"].sample }

      it "should update the onboarding's events correctly" do
        track_event

        expect(onboarding.events.count).to eq(1)
        expect(onboarding.events.first["additional_info"]).to be_nil
        expect(onboarding.events.first["created_at"]).to_not be_nil
        expect(onboarding.events.first["name"]).to eq(event)
      end
    end

    context "an event with additional_info" do
      let!(:additional_info) { ["error creating account", "error with something else"].sample }
      let!(:event) { ["new_solo_account_chosen", "new_stripe_account_created"].sample }

      it "should update the onboarding's events correctly" do
        track_event

        expect(onboarding.events.count).to eq(1)
        expect(onboarding.events.first["additional_info"]).to eq(additional_info)
        expect(onboarding.events.first["created_at"]).to_not be_nil
        expect(onboarding.events.first["name"]).to eq(event)        
      end
    end
  end

  describe "#find_event(event)" do
    subject(:find_event) { onboarding.find_event(event_name) }

    let!(:onboarding) { FactoryBot.create(:onboarding) }

    context "an event that exists" do
      let!(:event_name) { ["new_solo_account_chosen", "new_stripe_account_created"].sample }

      before { onboarding.track_event(event_name) }

      it "should find the event" do
        expect(find_event["name"]).to eq event_name
      end
    end

    context "an event that doesn't exist" do
      let!(:event_name) { Faker::Lorem.word }

      it "should return nil" do
        expect(find_event).to be_nil
      end
    end
  end

  describe "#solo_founder?" do
    subject(:solo_founder?) { onboarding.solo_founder? }

    let!(:onboarding) { FactoryBot.create(:onboarding) }

    context "when new_solo_account_chosen event has been created" do
      before { onboarding.track_event("new_solo_account_chosen") }

      it { expect(solo_founder?).to eq true }
    end

    context "when new_solo_account_chosen event has not been created" do
      it { expect(solo_founder?).to eq false }
    end
  end
end
