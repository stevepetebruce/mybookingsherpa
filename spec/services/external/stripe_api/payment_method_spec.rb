require "rails_helper"

RSpec.describe External::StripeApi::PaymentMethod, type: :model do
  describe "#list" do
    subject(:list) { described_class.list(customer_id, use_test_api: use_test_api) }

    context "valid and successful" do
      let(:customer_id) { "cus_#{Faker::Crypto.md5}" }
      let!(:use_test_api) { [true, false].sample }

      it "should call the Stripe PaymentMethod API with the correct attributes" do
        expect(Stripe::PaymentMethod).to receive(:list).with(customer: customer_id, type: "card")

        list
      end

      it "should return a list of Stripe PaymentMethod objects" do
        # TODO: need to get a payment method response and return it
      end
    end
  end
end

