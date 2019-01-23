require "rails_helper"

RSpec.describe Currency, type: :model do
  describe "#iso_to_symbol" do
    subject(:iso_to_symbol) { described_class.iso_to_symbol(iso) }

    context "valid and successful" do
      let!(:iso) { %i[eur gbp usd].sample }
      let(:expected_symbol) { { eur: "€", gbp: "£", usd: "$" }.fetch(iso) }

      it "should return the correct currency symbol" do
        expect(iso_to_symbol).to eq expected_symbol
      end
    end

    context "a currency symbol that does not exist" do
      let!(:iso) { Faker::Lorem.word }

      it "should throw a KeyError" do
        expect{ iso_to_symbol }.to raise_error(KeyError)
      end
    end
  end
end
