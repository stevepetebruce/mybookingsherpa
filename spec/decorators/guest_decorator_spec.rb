require "rails_helper"

RSpec.describe GuestDecorator, type: :model do
  let!(:guest) { FactoryBot.create(:guest) }

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

  describe "#status" do
    subject(:status) { described_class.new(guest).status(trip) }

    let(:trip) { FactoryBot.create(:trip) }

    context "booking is incomplete / yellow" do
      let!(:booking) { FactoryBot.create(:booking, guest: guest, trip: trip) }

      it "should return the correct flag" do
        expect(status).to eq "dot-warning"
      end
    end

    context "booking is complete / green" do
      let(:booking) { FactoryBot.create(:booking, :all_fields_complete, guest: guest, trip: trip) }
      let!(:payment) { FactoryBot.create(:payment, amount: booking.full_cost, booking: booking) }

      before { booking.update(updated_at: Time.zone.now) }

      it "should return the correct flag" do
        expect(status).to eq "dot-success"
      end
    end
  end
end
