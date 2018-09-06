require 'rails_helper'

RSpec.describe Guide, type: :model do
  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:trips) }

    context 'inheritance' do
      subject { Guide.superclass }
      it { should eq(User) }
    end
  end

  describe 'validations' do
    context 'type' do
      subject { FactoryBot.build(:guide).type }
      it { should eq('Guide') }
    end
  end
end
