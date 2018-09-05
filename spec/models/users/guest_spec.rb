require 'rails_helper'

RSpec.describe Guest, type: :model do
  describe 'associations' do
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
