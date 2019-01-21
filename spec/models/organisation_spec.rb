require "rails_helper"

RSpec.describe Organisation, type: :model do
  describe "associations" do
    it { should have_many(:guides).through(:organisation_memberships) }
    it { should have_many(:subscriptions) }
    it { should have_many(:trips) }
    # TODO: 
    # has_many: accomodation_providers
  end

  describe "validations" do
    it { should validate_presence_of(:currency) }

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

  describe "#plan" do
    let(:organisation) { FactoryBot.create(:organisation) }

    let!(:other_plan) { FactoryBot.create(:plan, flat_fee_amount: Faker::Number.decimal(2)) }
    let!(:other_subscription) { FactoryBot.create(:subscription,organisation: organisation, plan: other_plan, created_at: 10.days.ago) }
    let!(:current_plan) { FactoryBot.create(:plan, flat_fee_amount: Faker::Number.decimal(2)) }
    let!(:current_subscription) { FactoryBot.create(:subscription, organisation: organisation, plan: current_plan, created_at: Time.zone.now) }

    it "should be the plan associated with the most recently created subscription" do
      expect(organisation.plan).to eq current_plan
    end
  end

  it { should define_enum_for(:currency).with(%i[eur gbp usd]) }
end
