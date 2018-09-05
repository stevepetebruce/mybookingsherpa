require 'rails_helper'

RSpec.describe Guest, type: :model do
  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:trips) }

    context 'inheritance' do
      subject { Guest.superclass }
      it { should eq(User) }
    end
  end
  describe 'validations' do
    context 'type' do
      subject { FactoryBot.build(:guest).type }
      it { should eq('Guest') }
    end
  end
end
