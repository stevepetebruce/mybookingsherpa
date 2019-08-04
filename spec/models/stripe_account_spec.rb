require "rails_helper"

RSpec.describe StripeAccount, type: :model do
  describe "associations" do
    it { should belong_to(:organisation) }
  end
end
