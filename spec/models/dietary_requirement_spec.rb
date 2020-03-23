require "rails_helper"

RSpec.describe DietaryRequirement, type: :model do
  describe "associations" do
    it { should belong_to(:dietary_requirable).optional(true) }
  end

  describe "validations" do
    describe "name" do
      it { should_not allow_values(Faker::Lorem.word).for(:name) }
      it { should_not allow_values(nil, "").for(:name) }
      it { should allow_value("vegan", "vegetarian", "other").for(:name) }
    end
  end
end
