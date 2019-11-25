require "rails_helper"

RSpec.describe Organisation, type: :model do
  describe "associations" do
    it { should have_many(:company_people) }
    it { should have_many(:guides).through(:organisation_memberships) }
    it { should have_many(:trips) }
    it { should have_one(:onboarding) }
    it { should have_one(:subscription) }
    # TODO: has_many: accomodation_providers
  end

  it { should define_enum_for(:currency).with(%i[eur gbp usd]) }

  describe "callbacks" do
    let!(:organisation) { FactoryBot.build(:organisation) }

    it "should call #create_onboarding after_create" do
      expect(organisation).to receive(:create_onboarding)

      organisation.save
    end
  end

  describe "validations" do
    describe "deposit_percentage" do
      it { should validate_numericality_of(:deposit_percentage).only_integer }
    end

    describe "full_payment_window_weeks" do
      it { should validate_numericality_of(:full_payment_window_weeks).only_integer }
    end

    describe "name" do
      it { should allow_value(Faker::Lorem.word).for(:name) }
      it { should_not allow_value("<SQL INJECTION>").for(:name) }
    end

    describe "stripe_account_id_test" do
      it { should allow_value("acct_#{Faker::Number.number(15)}").for(:stripe_account_id_test) }
      it { should_not allow_value("!<>*&^%").for(:stripe_account_id_test) }
    end

    describe "stripe_account_id_live" do
      it { should allow_value("acct_#{Faker::Number.number(15)}").for(:stripe_account_id_live) }
      it { should_not allow_value("!<>*&^%").for(:stripe_account_id_live) }
    end

    describe "subdomain" do
      it { should allow_value(Faker::Internet.domain_word).for(:subdomain) }
      it { should_not allow_value("-#{Faker::Internet.domain_word}").for(:subdomain) } # beginning with "-"
      it { should_not allow_value("!<>*&^%").for(:subdomain) }
      it { should_not allow_value("12").for(:subdomain) } # < 3 digits
    end
  end

  describe "#on_trial?" do
    subject(:on_trial?) { organisation.on_trial? }

    let(:onboarding) { organisation.onboarding }
    let(:organisation) { FactoryBot.create(:organisation) }

    context "organisation who's completed onboarding" do
      before { onboarding.update_columns(complete: true) }

      it { expect(on_trial?).to be false }
    end

    context "organisation who hasn't completed onboarding" do
      it { expect(on_trial?).to be true }
    end
  end

  describe "#owner" do
    subject { organisation.owner }

    let!(:not_owner) { FactoryBot.create(:guide) }
    let(:organisation) { FactoryBot.create(:organisation) }
    let!(:organisation_membership) do
      FactoryBot.create(:organisation_membership,
                        guide: owner,
                        organisation: organisation,
                        owner: true)
    end
    let!(:owner) { FactoryBot.create(:guide) }

    it { expect(subject).to eq owner }
    it { expect(subject).to_not eq not_owner }
  end

  describe "#plan" do
    subject(:plan) { organisation.plan }

    let(:organisation) { FactoryBot.create(:organisation) }
  
    context "organisation on a plan" do
      let!(:other_plan) { FactoryBot.create(:plan, :flat_fee) }
      let!(:other_subscription) { FactoryBot.create(:subscription, organisation: organisation, plan: other_plan, created_at: 10.days.ago) }
      let!(:current_plan) { FactoryBot.create(:plan, :flat_fee) }
      let!(:current_subscription) { FactoryBot.create(:subscription, organisation: organisation, plan: current_plan, created_at: Time.zone.now) }
    
      it "should be the plan associated with the most recently created subscription" do
        # TODO: should only have one subscription... need to delete the old one... when a new one is created
        expect(plan).to eq current_plan
      end
    end
  end

  describe "#stripe_account_id" do
    subject(:stripe_account_id) { organisation.stripe_account_id }

    let(:organisation) { FactoryBot.create(:organisation) }

    context "organisation on trial" do
      before { allow(organisation).to receive(:on_trial?).and_return(true) }

      it "should return the organisation's stripe_account_id_test" do
        expect(stripe_account_id).to eq organisation.stripe_account_id_test
      end
    end

    context "organisation not on trial" do
      before { allow(organisation).to receive(:on_trial?).and_return(false) }

      it "should return the organisation's stripe_account_id_live" do
        expect(stripe_account_id).to eq organisation.stripe_account_id_live
      end
    end
  end
end
