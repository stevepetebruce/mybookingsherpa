require "rails_helper"

RSpec.describe GuestDecorator, type: :model do
  let(:guest) { FactoryBot.create(:guest) }

  describe "#dynamically created fallback fields" do
    subject(:dynamic_value) { described_class.new(guest).send(dynamically_created_field) }

    let!(:dynamically_created_field) { Guest::UPDATABLE_FIELDS.sample }

    context "a guest that does not have a name yet, but their most recent booking does" do
      let!(:booking) { FactoryBot.create(:booking, :all_fields_complete, guest: guest) }

      it "should return the booking name" do
        expect(dynamic_value).to eq booking.send(dynamically_created_field)
      end
    end
  end

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

  describe "#status_alert?" do
    subject(:status_alert?) { described_class.new(guest).status_alert?(trip) }

    let(:trip) { FactoryBot.create(:trip) }

    context "booking has incomplete personal details" do
      let!(:booking) { FactoryBot.create(:booking, guest: guest, trip: trip) }

      it { expect(status_alert?).to eq true }
    end

    context "booking has complete booking details but requires payment" do
      let!(:booking) { FactoryBot.create(:booking, :all_fields_complete, guest: guest, trip: trip) }

      it { expect(status_alert?).to eq true }
    end

    context "payment complete" do
      let!(:payment) { FactoryBot.create(:payment, amount: booking.full_cost, booking: booking) }

      context "booking has complete booking details" do
        let(:booking) { FactoryBot.create(:booking, :complete_without_any_issues, guest: guest, trip: trip) }

        it { expect(status_alert?).to eq false }
      end

      context "booking has complete booking details and has allergies" do
        let(:booking) { FactoryBot.create(:booking, :complete_with_allergies, guest: guest, trip: trip) }

        it { expect(status_alert?).to eq true }
      end

      context "booking has complete booking details and has dietary requirements" do
        let(:booking) { FactoryBot.create(:booking, :complete_with_dietary_requirements, guest: guest, trip: trip) }

        it { expect(status_alert?).to eq true }
      end

      context "booking has complete booking details and has medical_conditions" do
        let(:booking) { FactoryBot.create(:booking, :complete_with_medical_conditions, guest: guest, trip: trip) }

        it { expect(status_alert?).to eq true }
      end
    end
  end

  describe "#status_text" do
    subject(:status_text) { described_class.new(guest).status_text(trip) }

    let(:trip) { FactoryBot.create(:trip) }

    context "booking has incomplete personal details" do
      let!(:booking) { FactoryBot.create(:booking, guest: guest, trip: trip) }

      it { expect(status_text).to eq "Incomplete booking details" }
    end

    context "booking has complete booking details but requires payment" do
      let!(:booking) { FactoryBot.create(:booking, :all_fields_complete, guest: guest, trip: trip) }

      it { expect(status_text).to eq "Payment required" }
    end

    context "payment complete" do
      let!(:payment) { FactoryBot.create(:payment, amount: booking.full_cost, booking: booking) }

      context "booking has complete booking details" do
        let(:booking) { FactoryBot.create(:booking, :complete_without_any_issues, guest: guest, trip: trip) }

        it { expect(status_text).to be_nil }
      end

      context "booking has complete booking details and has allergies" do
        let(:booking) { FactoryBot.create(:booking, :complete_with_allergies, guest: guest, trip: trip) }

        it { expect(status_text).to eq "Allergies" }
      end

      context "booking has complete booking details and has dietary requirements" do
        let(:booking) { FactoryBot.create(:booking, :complete_with_dietary_requirements, guest: guest, trip: trip) }

        it { expect(status_text).to eq "Dietary requirements" }
      end

      context "booking has complete booking details and has medical_conditions" do
        let(:booking) { FactoryBot.create(:booking, :complete_with_medical_conditions, guest: guest, trip: trip) }

        it { expect(status_text).to eq "Medical conditions" }
      end
    end
  end
end
