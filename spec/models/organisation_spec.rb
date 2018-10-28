require 'rails_helper'

RSpec.describe Organisation, type: :model do
  describe 'associations' do
    # TODO: 
    # has_many: memberships: organisation_guide join table
    # has_many: subscriptions (including one current_subscription)
    # has_many: accomodation_providers
  end

  describe 'validations' do
    context 'name' do
      it { should allow_value(Faker::Lorem.word).for(:name) }
      it { should_not allow_value('<SQL INJECTION>').for(:name) }
    end
    context 'stripe_account_id' do
      it { should allow_value("acct_#{Faker::Number.number(15)}").for(:stripe_account_id) }
      it { should_not allow_value("!<>*&^%").for(:stripe_account_id) }
    end
    context 'subdomain' do
      it { should allow_value(Faker::Internet.domain_word).for(:subdomain) }
      it { should_not allow_value("-#{Faker::Internet.domain_word}").for(:subdomain) } # beginning with '-'
      it { should_not allow_value("!<>*&^%").for(:subdomain) }
      it { should_not allow_value("12").for(:subdomain) } # < 3 digits
    end
  end
end
