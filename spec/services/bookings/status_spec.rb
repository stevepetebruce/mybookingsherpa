require "rails_helper"

RSpec.describe Bookings::Status, type: :model do
  describe "#allergies?" do
    subject(:allergies?) { described_class.new(booking).allergies? }

    let!(:allergy) { %i[dairy eggs nuts soya].sample }

    context "a booking that has no allergies" do
      let(:booking) { FactoryBot.create(:booking, guest: guest) }

      context "a guest associated with the booking that has no allergies" do
        let(:guest) { FactoryBot.create(:guest) }

        it { expect(allergies?).to eq false }
      end

      context "a guest associated with the booking that has allergies" do
        let!(:guest) do
          FactoryBot.create(:guest, email: 'foo@blah.com',
                            allergies: allergy,
                            allergies_override: allergy)
        end

        it { expect(allergies?).to eq true }
      end
    end

    context "a booking that has allergies" do
      let(:booking) { FactoryBot.create(:booking, guest: guest, allergies: allergy) }

      context "a guest associated with the booking that has no allergies" do
        let(:guest) { FactoryBot.create(:guest) }

        it { expect(allergies?).to eq true }
      end

      context "a guest associated with the booking that has allergies" do
        let(:guest) { FactoryBot.create(:guest, allergies: allergy) }

        it { expect(allergies?).to eq true }
      end
    end
  end

  describe "#dietary_requirements?" do
    subject(:dietary_requirements?) { described_class.new(booking).dietary_requirements? }

    let!(:dietary_requirement) { %i[other vegan vegetarian].sample }

    context "a booking that has no dietary_requirements" do
      let(:booking) { FactoryBot.create(:booking, guest: guest) }

      context "a guest associated with the booking that has no dietary_requirements" do
        let(:guest) { FactoryBot.create(:guest) }

        it { expect(dietary_requirements?).to eq false }
      end

      context "a guest associated with the booking that has dietary_requirements" do
        let!(:guest) do
          FactoryBot.create(:guest, email: 'foo@blah.com',
                            dietary_requirements: dietary_requirement,
                            dietary_requirements_override: dietary_requirement)
        end

        it { expect(dietary_requirements?).to eq true }
      end
    end

    context "a booking that has dietary_requirements" do
      let(:booking) { FactoryBot.create(:booking, guest: guest, dietary_requirements: dietary_requirement) }

      context "a guest associated with the booking that has no dietary_requirements" do
        let(:guest) { FactoryBot.create(:guest) }

        it { expect(dietary_requirements?).to eq true }
      end

      context "a guest associated with the booking that has dietary_requirements" do
        let(:guest) { FactoryBot.create(:guest, dietary_requirements: dietary_requirement) }

        it { expect(dietary_requirements?).to eq true }
      end
    end
  end

  describe "#other_information?" do
    subject(:other_information?) { described_class.new(booking).other_information? }

    let!(:medical_condition) { %w[asthma vertigo arthritis].sample }

    context "a booking that has no other_information" do
      let(:booking) { FactoryBot.create(:booking, guest: guest) }

      context "a guest associated with the booking that has no other_information" do
        let(:guest) { FactoryBot.create(:guest) }

        it { expect(other_information?).to eq false }
      end

      context "a guest associated with the booking that has other_information" do
        let!(:guest) do
          FactoryBot.create(:guest, email: 'foo@blah.com',
                            other_information: medical_condition,
                            other_information_override: medical_condition)
        end

        it { expect(other_information?).to eq true }
      end
    end

    context "a booking that has other_information" do
      let(:booking) { FactoryBot.create(:booking, guest: guest, other_information: medical_condition) }

      context "a guest associated with the booking that has no other_information" do
        let(:guest) { FactoryBot.create(:guest) }

        it { expect(other_information?).to eq true }
      end

      context "a guest associated with the booking that has other_information" do
        let(:guest) { FactoryBot.create(:guest, other_information: medical_condition) }

        it { expect(other_information?).to eq true }
      end
    end
  end
end
