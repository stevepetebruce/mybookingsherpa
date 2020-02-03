require "rails_helper"

RSpec.describe Bookings::StripeCustomer, type: :model do
  describe "#id" do
    subject(:id) { described_class.new(booking, stripe_payment_method).id }

    let(:create_attributes) do
      {
        description: "#{guest.email}",
        payment_method: stripe_payment_method
      }
    end
    let(:booking) { FactoryBot.create(:booking, guest: guest) }
    let!(:stripe_customer_id) { "cus_#{Faker::Crypto.md5}" }
    let(:stripe_payment_method) { "pm_#{Faker::Crypto.md5}" }

    context "booking / guest does not have an existing stripe_customer_id" do
      let!(:guest) { FactoryBot.create(:guest, stripe_customer_id: nil) }

      it "should create a new customer in Stripe and return its id" do
        expect(External::StripeApi::Customer).
          to receive(:create).
          with(create_attributes,
               stripe_account: booking.organisation_stripe_account_id,
               use_test_api: booking.organisation_on_trial?).
          and_return(double(id: stripe_customer_id))

        expect(id).to eq stripe_customer_id
      end
    end

    context "booking / guest has stripe_customer_id and customer is not deleted in Stripe API" do
      before do
        allow(External::StripeApi::Customer).
        to receive(:retrieve).
        with({ customer_id: stripe_customer_id, use_test_api: booking.organisation_on_trial? }).
        and_return(double(deleted?: false, present?: true))
      end

      let!(:booking) { FactoryBot.create(:booking, guest: guest, stripe_customer_id: stripe_customer_id) }
      let!(:guest) { FactoryBot.create(:guest, stripe_customer_id: stripe_customer_id) }

      it "should not create a new customer and return existing stripe_customer_id" do
        expect(External::StripeApi::Customer).not_to receive(:create)

        expect(id).to eq stripe_customer_id
      end
    end

    context "booking / guest has stripe_customer_id but customer is not present in Stripe API" do
      # Possibly because they were deleted over 7 years ago
      before do
        allow(External::StripeApi::Customer).
        to receive(:retrieve).
        with({ customer_id: stripe_customer_id, use_test_api: booking.organisation_on_trial? }).
        and_raise(Stripe::InvalidRequestError.new("error message", "error param"))
      end

      let!(:guest) { FactoryBot.create(:guest, stripe_customer_id: stripe_customer_id) }
      let!(:new_stripe_customer_id) { "cus_#{Faker::Crypto.md5}" }

      it "should create a new customer and return new stripe_customer_id" do
        expect(External::StripeApi::Customer).
          to receive(:create).
          with(create_attributes,
               stripe_account: booking.organisation_stripe_account_id,
               use_test_api: booking.organisation_on_trial?).
          and_return(double(id: new_stripe_customer_id))

        expect(id).to eq new_stripe_customer_id
      end
    end

    context "booking / guest has stripe_customer_id but customer is deleted in Stripe API" do
      before do
        allow(External::StripeApi::Customer).
        to receive(:retrieve).
        with({ customer_id: deleted_stripe_customer_id, use_test_api: booking.organisation_on_trial? }).
        and_return(double(deleted?: true, present?: true))
      end

      let!(:deleted_stripe_customer_id) { "cus_#{Faker::Crypto.md5}" }
      let!(:guest) { FactoryBot.create(:guest, stripe_customer_id: deleted_stripe_customer_id) }

      it "should create a new customer in Stripe and return its id" do
        expect(External::StripeApi::Customer).
          to receive(:create).
          with(create_attributes,
               stripe_account: booking.organisation_stripe_account_id,
               use_test_api: booking.organisation_on_trial?).
          and_return(double(id: stripe_customer_id))

        expect(id).to eq stripe_customer_id
      end
    end
  end
end
