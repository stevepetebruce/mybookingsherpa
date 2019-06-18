require "rails_helper"

RSpec.describe Bookings::Payment, type: :model do
  describe "#charge" do
    subject(:charge) { described_class.new(booking).charge }

    let(:booking) { FactoryBot.create(:booking, trip: trip) }
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
      let(:trip) { FactoryBot.create(:trip) }

      it "should not raise an exception" do
        expect { charge }.to_not raise_exception
      end

      it "should return something other than nil" do
        expect(charge).to_not be_nil
      end

      describe "destination fee for different priced trips" do
        let(:charge_description) do
            "#{Currency.iso_to_symbol(trip.currency)}" \
              "#{Currency.human_readable(trip_full_cost_in_cents)} " \
              "paid to #{booking.organisation_name} for #{booking.trip_name}"
          end
          let(:transfer_data) do
            {
              destination: booking.organisation_stripe_account_id
            }
          end
          let(:trip_full_cost_in_cents) { trip.full_cost * 100 }

        context "a trip that is under the minimum trip cost" do
          let(:trip) { FactoryBot.create(:trip, full_cost: 10_000) }

          it "should use the lower destination fee" do
            expect(External::StripeApi::Charge).
              to receive(:create).
              with({
                amount: trip_full_cost_in_cents,
                application_fee_amount: 200, 
                currency: trip.currency,
                customer: nil,
                description: charge_description,
                transfer_data: transfer_data,
                use_test_api: true
               })

            charge
          end
        end

        context "a trip that is over the minimum trip cost" do
          let(:trip) { FactoryBot.create(:trip, full_cost: 500_000) }

          it "should use the regular destination fee" do
            expect(External::StripeApi::Charge).
              to receive(:create).
              with({
                amount: trip_full_cost_in_cents,
                application_fee_amount: 400, 
                currency: trip.currency,
                customer: nil,
                description: charge_description,
                transfer_data: transfer_data,
                use_test_api: true
               })

            charge
          end
        end
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
