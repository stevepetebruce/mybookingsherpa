require "rails_helper"

RSpec.describe Allergy, type: :model do
  describe "associations" do
    it { should belong_to(:allergic) }
  end

  describe "validations" do
    context "name" do
      it { should_not allow_values(Faker::Lorem.word).for(:name) }
      it { should_not allow_values(nil, "").for(:name) }
      it do 
        should allow_value("dairy", "eggs", "fish", "gluten", "nuts", "other", "shellfish", "soya").
          for(:name)
      end
    end
  end
end
