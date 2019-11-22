require "rails_helper"

RSpec.describe TripDecorator, type: :model do
  let!(:trip) { FactoryBot.create(:trip) }
  let!(:organisation) { trip.organisation }

  describe "#new_public_booking_link" do
    subject (:new_public_booking_link) { trip.new_public_booking_link }

    context "on staging" do
      before { allow(Settings).to receive(:env_staging?).and_return(true) }

      context "organisation in trial" do
        it "should return the in-trial warning URL" do
          expect(new_public_booking_link).to eq "#{ENV.fetch('PUBLIC_BOOKING_DOMAIN').split('//').first}"\
              "//#{trip.organisation_subdomain_or_www}"\
              "#{ENV.fetch('PUBLIC_BOOKING_DOMAIN').split('//').last}"\
              "/public/trips/#{trip.slug}/bookings/new"\
              "?DO_NOT_SHARE_IN_TRIAL_EXAMPLE_PLEASE_COMPLETE_YOUR_ACCOUNT_SET_UP"
        end
      end

      context "organisation who has completed onboarding" do
        before { organisation.onboarding.update_columns(complete: true) }

        it "should return the live URL (without the in-trial warning" do
          expect(new_public_booking_link).to eq "#{ENV.fetch('PUBLIC_BOOKING_DOMAIN').split('//').first}"\
            "//#{trip.organisation_subdomain_or_www}"\
            "#{ENV.fetch('PUBLIC_BOOKING_DOMAIN').split('//').last}"\
            "/public/trips/#{trip.slug}/bookings/new"
        end
      end
    end

    context "on production" do
      before { allow(Settings).to receive(:env_staging?).and_return(false) }

      context "organisation in trial" do
        it "should return the in-trial warning URL" do
          expect(new_public_booking_link).to eq "#{ENV.fetch('PUBLIC_BOOKING_DOMAIN').split('//').first}"\
              "//#{trip.organisation_subdomain_or_www}."\
              "#{ENV.fetch('PUBLIC_BOOKING_DOMAIN').split('//').last}"\
              "/public/trips/#{trip.slug}/bookings/new"\
              "?DO_NOT_SHARE_IN_TRIAL_EXAMPLE_PLEASE_COMPLETE_YOUR_ACCOUNT_SET_UP"
        end
      end

      context "organisation who has completed onboarding" do
        before { organisation.onboarding.update_columns(complete: true) }

        it "should return the live URL (without the in-trial warning" do
          expect(new_public_booking_link).to eq "#{ENV.fetch('PUBLIC_BOOKING_DOMAIN').split('//').first}"\
            "//#{trip.organisation_subdomain_or_www}."\
            "#{ENV.fetch('PUBLIC_BOOKING_DOMAIN').split('//').last}"\
            "/public/trips/#{trip.slug}/bookings/new"
        end
      end
    end
  end
end
