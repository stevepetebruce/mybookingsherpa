require "rails_helper"

RSpec.describe GuestDecorator, type: :model do
  let!(:guest) { FactoryBot.build(:guest) }

  describe "#gravatar_url" do
    subject { described_class.new(guest).gravatar_url }

    let(:gravatar_id) { Digest::MD5.hexdigest(guest.email).downcase }

    it "should return expected URL" do
      expect(subject).to start_with "http://gravatar.com/avatar/#{gravatar_id}"
    end
  end

  describe "#flag_icon" do
    subject { described_class.new(guest).flag_icon }

    it "should return expected flag-icon class" do
      expect(["flag-icon-fr", "flag-icon-gb", "flag-icon-us"]).to include(subject)
    end
  end
end
