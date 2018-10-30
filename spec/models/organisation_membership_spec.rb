require 'rails_helper'

RSpec.describe OrganisationMembership, type: :model do
  describe 'associations' do
    it { should belong_to(:guide) }
    it { should belong_to(:organisation) }
  end

  describe 'validations' do
    context 'uniqueness' do
      context 'a guide is a member of an organisation once' do
        let!(:organisation) { FactoryBot.create(:organisation) }
        let!(:guide) { FactoryBot.create(:guide) }
        let!(:organisation_membership) do
          FactoryBot.build(:organisation_membership, guide: guide, organisation: organisation)
        end

        it { expect(organisation_membership).to be_valid }
      end

      context 'a guide is a member of the same organisation twice' do
        let!(:organisation) { FactoryBot.create(:organisation) }
        let!(:guide) { FactoryBot.create(:guide) }
        let!(:organisation_membership) do 
          FactoryBot.create(:organisation_membership, guide: guide, organisation: organisation)
        end
        let!(:duplicate_organisation_membership) do 
          FactoryBot.build(:organisation_membership, guide: guide, organisation: organisation)
        end

        it { expect(duplicate_organisation_membership).to_not be_valid }
      end
    end
  end
end
