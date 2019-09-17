require "rails_helper"

RSpec.describe Currency, type: :model do
  describe "#country_code_to_iso" do
    subject(:country_code_to_iso) { described_class.country_code_to_iso(country_code) }

    context "gb country_code" do
      let(:country_code) { "gb" }

      it { expect(country_code_to_iso).to eq "gbp" }
    end

    context "us country_code" do
      let(:country_code) { "us" }

      it { expect(country_code_to_iso).to eq "usd" }
    end

     context "non gb or us country_code" do
      let(:country_code) { "fr" }

      it { expect(country_code_to_iso).to eq "eur" }
    end
  end

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
