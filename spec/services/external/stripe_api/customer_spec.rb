require "rails_helper"

RSpec.describe External::StripeApi::Customer, type: :model do
  describe "#create" do
    subject(:create) { described_class.create(attributes) }
    let(:use_test_api) { [true, false].sample }
    
    context "successfully creates customer" do
      let!(:attributes) do
        {
          description: "Customer for #{Faker::Internet.email}",
          payment_method: "pm_#{Faker::Crypto.md5}",
          use_test_api: use_test_api
        }
      end
      let(:expected_attributes) do
        {
          description: attributes[:description],
          payment_method: attributes[:payment_method]
        }
      end

      it "should call Stripe::Customer#create" do
        pending 'Jan 2020 rush job'
        expect(Stripe::Customer).to receive(:create).with(expected_attributes)

        create
      end
    end
  end

  describe "#retrieve" do
    subject(:retrieve) { described_class.retrieve(attributes) }
    let(:use_test_api) { [true, false].sample }

    let!(:attributes) do
      {
        customer_id: "cus_#{Faker::Crypto.md5}",
        use_test_api: use_test_api
      }
    end

    it "should call Stripe::Customer#retrieve" do
      expect(Stripe::Customer).to receive(:retrieve).with(attributes[:customer_id])

      retrieve
    end
  end
end
