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

    context "unsuccesful" do
      context "organisation does not have a stripe account id set" do
        let(:booking) { FactoryBot.create(:booking, trip: trip) }
        let!(:organisation_no_stripe_account_id) { FactoryBot.create(:organisation, :without_stripe_account_id) }
        let(:trip) { FactoryBot.create(:trip, organisation: organisation_no_stripe_account_id) }

        it "should throw a NoOrganisationStripeAccountIdError" do
           expect { charge }.to raise_error(NoOrganisationStripeAccountIdError)
        end
      end
    end
  end
end
