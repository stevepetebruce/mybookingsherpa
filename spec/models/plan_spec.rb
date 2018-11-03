require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe 'associations' do
    it { should have_many(:subscriptions) }
  end

  describe 'validations' do
    context 'name' do
      it { should validate_presence_of(:name)  }
    end
    context 'flat_fee_amount' do
      subject { FactoryBot.build(:plan, charge_type: :flat_fee) }
      it { should validate_presence_of(:flat_fee_amount)  }
    end
    context 'percentage_amount' do
      subject { FactoryBot.build(:plan, charge_type: :percentage) }
      it { should validate_presence_of(:percentage_amount) }
    end
  end

  it { should define_enum_for(:charge_type).with([:flat_fee, :percentage ]) }
end
