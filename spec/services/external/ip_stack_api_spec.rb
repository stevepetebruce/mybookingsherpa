require "rails_helper"

RSpec.describe External::IpStackApi, type: :model do
  describe "#country_code" do
    subject(:country_code) { described_class.country_code(ip_address) }

    context "gb based IP address" do
      before do
        stub_request(:get, "http://api.ipstack.com/#{ip_address}?access_key=#{ENV.fetch("IP_STACK_API_KEY")}").
          to_return(status: 200, body: "#{file_fixture("ip_stack_api/gb_response.json").read}", headers: {})
      end

      let(:ip_address) { "86.13.178.22" }

      it { expect(country_code).to eq "gb" }
    end

    context "fr based IP address" do
      before do
        stub_request(:get, "http://api.ipstack.com/#{ip_address}?access_key=#{ENV.fetch("IP_STACK_API_KEY")}").
          to_return(status: 200, body: "#{file_fixture("ip_stack_api/fr_response.json").read}", headers: {})
      end

      let(:ip_address) { "2.22.192.0" }

      it { expect(country_code).to eq "fr" }
    end
  end

  describe "#is_gb?" do
    subject(:is_gb?) { described_class.is_gb?(ip_address) }

    context "gb based IP address" do
      before do
        stub_request(:get, "http://api.ipstack.com/#{ip_address}?access_key=#{ENV.fetch("IP_STACK_API_KEY")}").
          to_return(status: 200, body: "#{file_fixture("ip_stack_api/gb_response.json").read}", headers: {})
      end

      let(:ip_address) { "86.13.178.22" }

      it { expect(is_gb?).to eq true }
    end

    context "fr based IP address" do
      before do
        stub_request(:get, "http://api.ipstack.com/#{ip_address}?access_key=#{ENV.fetch("IP_STACK_API_KEY")}").
          to_return(status: 200, body: "#{file_fixture("ip_stack_api/fr_response.json").read}", headers: {})
      end

      let(:ip_address) { "2.22.192.0" }

      it { expect(is_gb?).to eq false }
    end
  end
end