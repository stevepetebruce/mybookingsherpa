require "rails_helper"

RSpec.describe Onboarding, type: :model do
  describe "associations" do
    it { should belong_to(:organisation) }
  end
end
