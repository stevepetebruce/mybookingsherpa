require 'rails_helper'

RSpec.describe Guide, type: :model do
  describe 'associations' do
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
