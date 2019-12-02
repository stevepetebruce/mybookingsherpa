require "rails_helper"

RSpec.describe "Public::Trips::Bookings::FailedPaymentsController", type: :request do
  let(:booking) { last_failed_payment.booking }
  let(:last_failed_payment) { FactoryBot.create(:payment, :failed) }

  describe "#new GET /public/bookings/:booking_id/failed_payments/new" do
    before do
      stub_request(:post, "https://api.stripe.com/v1/payment_intents").
        to_return(status: 200,
                  body: "#{file_fixture("stripe_api/successful_payment_intent.json").read}",
                  headers: {})
    end

    def do_request(url: "/public/bookings/#{booking.id}/failed_payments/new", params: {})
      get url, params: params
    end

    context "valid and successful" do
      it "should successfully render" do
        do_request

        expect(response).to be_successful
      end
    end
  end

  describe "#create POST /public/bookings/:booking_id/failed_payments" do
    def do_request(url: "/public/bookings/#{booking.id}/failed_payments", params: {})
      post url, params: params
    end

    let(:expected_redirect_url) do
      url_for(controller: "/public/trips/bookings/failed_payments",
                          action: "show",
                          id: booking.id,
                          subdomain: booking.organisation_subdomain_or_www,
                          tld_length: 1)
    end

    context "valid and successful" do
      it "should redirect to failed_payments show view" do
        do_request

        expect(response.code).to eq "302"
        expect(response).to redirect_to expected_redirect_url
      end
    end
  end

  describe "#show GET /public/bookings/:id/" do
    def do_request(url: "/public/bookings/#{booking.id}", params: {})
      get url, params: params
    end

    context "valid and successful" do
      it "should successfully render" do
        do_request

        expect(response).to be_successful
      end
    end
  end
end