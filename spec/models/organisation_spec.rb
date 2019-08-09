require "rails_helper"

RSpec.describe Organisation, type: :model do
  describe "associations" do
    it { should have_many(:guides).through(:organisation_memberships) }
    it { should have_many(:subscriptions) }
    it { should have_many(:trips) }
    # TODO: has_many: accomodation_providers
  end

  it { should define_enum_for(:currency).with(%i[eur gbp usd]) }

  describe "validations" do
    describe "deposit_percentage" do
      it { should validate_numericality_of(:deposit_percentage).only_integer }
    end

    describe "full_payment_window_weeks" do
      it { should validate_numericality_of(:full_payment_window_weeks).only_integer }
    end

    context "name" do
      it { should allow_value(Faker::Lorem.word).for(:name) }
      it { should_not allow_value("<SQL INJECTION>").for(:name) }
    end
    context "stripe_account_id" do
      it { should allow_value("acct_#{Faker::Number.number(15)}").for(:stripe_account_id) }
      it { should_not allow_value("!<>*&^%").for(:stripe_account_id) }
    end
    context "subdomain" do
      it { should allow_value(Faker::Internet.domain_word).for(:subdomain) }
      it { should_not allow_value("-#{Faker::Internet.domain_word}").for(:subdomain) } # beginning with "-"
      it { should_not allow_value("!<>*&^%").for(:subdomain) }
      it { should_not allow_value("12").for(:subdomain) } # < 3 digits
    end
  end

  describe "#on_trial?" do
    subject(:on_trial?) { organisation.on_trial? }

    let(:organisation) { FactoryBot.create(:organisation) }

    context "organisation on a plan" do
      let!(:current_plan) { FactoryBot.create(:plan, flat_fee_amount: Faker::Number.decimal(2)) }
      let!(:current_subscription) { FactoryBot.create(:subscription, organisation: organisation, plan: current_plan, created_at: Time.zone.now) }

      it { expect(on_trial?).to be false }
    end

    context "organisation not on a plan" do
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
      let!(:other_plan) { FactoryBot.create(:plan, flat_fee_amount: Faker::Number.decimal(2)) }
      let!(:other_subscription) { FactoryBot.create(:subscription, organisation: organisation, plan: other_plan, created_at: 10.days.ago) }
      let!(:current_plan) { FactoryBot.create(:plan, flat_fee_amount: Faker::Number.decimal(2)) }
      let!(:current_subscription) { FactoryBot.create(:subscription, organisation: organisation, plan: current_plan, created_at: Time.zone.now) }
    
      it "should be the plan associated with the most recently created subscription" do
        # TODO: should only have one subscription... need to delete the old one... when a new one is created
        expect(plan).to eq current_plan
      end
    end
  end
end
