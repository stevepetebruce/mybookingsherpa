require "rails_helper"

RSpec.describe Bookings::Payment, type: :model do
  describe "#charge" do
    subject(:charge) { described_class.new(booking, token).charge }

    let(:booking) { FactoryBot.create(:booking) }
    let(:token) { "tok_#{Faker::Crypto.md5}" }
    let(:response_body) do
      "#{file_fixture("stripe_api/successful_charge.json").read}"
    end

    before do
      stub_request(:post, "https://api.stripe.com/v1/charges")
        .to_return(status: 200,
                   body: response_body,
                   headers: {})
    end

    context "successful" do
      it "should not raise an exception" do
        expect { charge }.to_not raise_exception
      end

      it "should return something other than nil" do
        expect(charge).to_not be_nil
      end
    end
  end
end
