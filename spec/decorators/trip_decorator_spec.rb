require "rails_helper"

RSpec.describe TripDecorator, type: :model do
  let!(:trip) { FactoryBot.create(:trip) }

  describe "#new_public_booking_link" do
    subject { described_class.new(trip).new_public_booking_link }

    it "should return expected URL" do
      expect(subject).to eq "#{ENV.fetch('PUBLIC_BOOKING_DOMAIN').split('//').first}"\
        "//#{trip.organisation_subdomain}."\
        "#{ENV.fetch('PUBLIC_BOOKING_DOMAIN').split('//').last}"\
        "/public/trips/#{trip.slug}/bookings/new"
    end
  end
end
