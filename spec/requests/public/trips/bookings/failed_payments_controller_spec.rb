require "rails_helper"

RSpec.describe "Public::Trips::Bookings::FailedPaymentsController", type: :request do
  describe "#new GET /public/bookings/:booking_id/failed_payments/new" do
    def do_request(url: "/public/bookings/#{booking.id}/failed_payments/new", params: {})
      get url, params: params
    end

    let(:booking) { FactoryBot.create(:booking, :with_failed_payment) }

    before do
      stub_request(:post, "https://api.stripe.com/v1/payment_intents").
        to_return(status: 200,
                  body: "#{file_fixture("stripe_api/successful_payment_intent.json").read}",
                  headers: {})
    end

    it "should successfully render" do
      do_request

      expect(response).to be_successful
    end
  end

  describe "#create POST /public/bookings/:booking_id/failed_payments" do
    def do_request(url: "/public/bookings/#{booking.id}/failed_payments", params: {})
      post url, params: params
    end

    let(:booking) { FactoryBot.create(:booking, :with_failed_payment) }

    let!(:params) do
      {
        booking_id: booking.id,
        stripePaymentMethod: "pm_#{Faker::Crypto.md5}",
        payment_intent_id: "cus_#{Faker::Crypto.md5}"
      }
    end

    context "valid and successful" do
      it "should create a new payment with status of success" do
        do_request(params: params)

        expect(booking.last_payment.success?).to eq true
      end

      it "should set the payment_status of the booking to full_amount_paid" do
        expect(booking.full_amount_paid?).to eq true
      end
    end
  end


  describe "#show GET /public/failed_payments/:id" do
    def do_request(url: "/public/failed_payments/#{booking.id}", params: {})
      get url, params: params
    end

    let(:booking) { FactoryBot.create(:booking, :with_failed_payment) }

    it "should successfully render" do
      do_request

      expect(response).to be_successful
    end
  end
end
