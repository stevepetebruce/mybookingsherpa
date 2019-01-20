require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:trip) }
    it { is_expected.to belong_to(:guest) }
  end

  describe 'validations' do
    context 'email' do
      it { should allow_value(Faker::Internet.email).for(:email) }
      it { should_not allow_value(Faker::Lorem.word).for(:email) }
      it { should validate_presence_of(:email) }
    end
  end

  it { should define_enum_for(:status).with(%i[pending complete]) }
end
