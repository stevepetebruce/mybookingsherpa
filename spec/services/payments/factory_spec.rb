require "rails_helper"

RSpec.describe Payments::Factory, type: :model do
  before do
    allow(Stripe::Charge).to receive(:new).and_return(stripe_charge)
    allow(stripe_charge).to receive(:to_h).and_return(raw_response)
  end

  let(:stripe_charge) { instance_double(Stripe::Charge) }

  describe "#create" do
    subject(:create) { described_class.new(booking, raw_response).create }
    let(:booking) { FactoryBot.create(:booking) }

    context "successful charge" do
      let(:raw_response) { JSON.parse("#{file_fixture("stripe_api/successful_charge.json").read}") }

      it "should create a new payment record associated with the booking" do
        expect { create }.to change { booking.payments.count }.from(0).to(1)
      end

      it "should have the correct amount value" do
        expect(create.amount).to eq raw_response.fetch("amount")
      end
    end
  end
end
