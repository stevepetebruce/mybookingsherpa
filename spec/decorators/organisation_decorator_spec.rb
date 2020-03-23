require "rails_helper"

RSpec.describe OrganisationDecorator, type: :model do
  let!(:onboarding) { FactoryBot.create(:onboarding, organisation: organisation) }
  let(:organisation) { FactoryBot.create(:organisation) }

  describe "#currency" do
    subject(:currency) { organisation.currency }

    context "when there's no currency set yet" do
      it "should use the default" do
        expect(currency).to eq "gbp"
      end
    end

    context "when the currency has been set" do
      before { organisation.update_columns(currency: "eur") }

      it "should use this value (and not the default)" do
        expect(currency).to eq "eur"
      end
    end
  end

  describe "#stripe_publishable_key" do
    subject(:stripe_publishable_key) { organisation.stripe_publishable_key }

    context "organisation on trial" do
      it "should be the STRIPE_PUBLISHABLE_KEY_LIVE" do
        expect(stripe_publishable_key).to eq ENV.fetch("STRIPE_PUBLISHABLE_KEY_TEST")
      end
    end

    context "organisation not on trial" do
      before { organisation.reload.onboarding.update_columns(complete: true) }

      it "should be the STRIPE_PUBLISHABLE_KEY_LIVE" do
        expect(stripe_publishable_key).to eq ENV.fetch("STRIPE_PUBLISHABLE_KEY_LIVE")
      end
    end
  end

  describe "#stripe_publishable_key_live" do
    subject(:stripe_publishable_key_live) { organisation.stripe_publishable_key_live }

    it { should eq ENV.fetch("STRIPE_PUBLISHABLE_KEY_LIVE") }
  end
end
