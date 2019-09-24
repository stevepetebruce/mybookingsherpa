require "rails_helper"

RSpec.describe CompanyPerson, type: :model do
  describe "associations" do
    it { should belong_to(:organisation) }
  end

  it { should define_enum_for(:relationship).with(%i[director owner]) }
end