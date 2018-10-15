require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:trip) }
    it { is_expected.to belong_to(:guest) }
  end

  it { should define_enum_for(:status).with([:pending, :complete]) }
end
