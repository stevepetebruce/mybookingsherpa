require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'associations' do
    it { should belong_to(:organisation) }
    it { should belong_to(:plan) }
  end
end
