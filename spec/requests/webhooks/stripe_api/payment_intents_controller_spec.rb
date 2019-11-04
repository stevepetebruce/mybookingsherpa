require "rails_helper"

RSpec.describe "Webhooks::StripeApi::PaymentIntentsController", type: :request do
  describe "#create POST /webhooks/stripe_api/payment_intents" do
    def do_request(url: "/webhooks/stripe_api/payment_intents", params: {}, headers: {})
      post url, params: params, headers: headers, as: :json
    end

    context "without valid signature" do
      let(:event) do 
        JSON.parse("#{file_fixture("/stripe_api/webhooks/payment_intents/successful_status_without_booking_id.json").read}")
      end
      let(:params) { event }

      it "should return a 400" do
        do_request(params: params)

        expect(response.code).to eq("400")
      end
    end

    context "with valid signature" do
      context "payment_intent.succeeded event - without pre-existing booking" do
        let(:event) do 
          JSON.parse("#{file_fixture("/stripe_api/webhooks/payment_intents/successful_status_without_booking_id.json").read}")
        end
        let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
        let(:params) { event }
        let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS"] }

        it "should respond with a success status code" do
          do_request(params: params, headers: headers)

          expect(response).to be_successful
        end

        it "should create a new payment" do
          expect { do_request(params: params, headers: headers) }.to change { Payment.count }.by(1)
          expect(Payment.last.amount).to eq 90_000 # from payment_intent_successful_status_with_booking_id.json
        end
      end

      context "payment_intent.succeeded event - with pre-existing booking" do
        let!(:booking) { FactoryBot.create(:booking, id: "2f2a2255-8b43-4574-9d33-b7f56d624026") }
        let(:event) do 
          JSON.parse("#{file_fixture("/stripe_api/webhooks/payment_intents/successful_status_with_booking_id.json").read}")
        end
        let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
        let(:params) { event }
        let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS"] }

        it "should respond with a success status code" do
          do_request(params: params, headers: headers)

          expect(response).to be_successful
        end

        it "should create a new payment associated with this booking" do
          do_request(params: params, headers: headers)

          expect(booking.payments.count).to eq 1
          expect(booking.payments.first.amount).to eq 90_000 # from payment_intent_successful_status_with_booking_id.json
        end
      end

      context "amount_capturable_updated event" do
        let(:event) do 
          JSON.parse("#{file_fixture("/stripe_api/webhooks/payment_intents/successful_status_amount_capturable_updated.json").read}")
        end
        let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
        let(:params) { event }
        let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS"] }

        it "should respond with a success status code" do
          do_request(params: params, headers: headers)

          expect(response).to be_successful
        end
        # TODO: should also probably do something else on our side...
      end
        
      context "payment_failed event" do
        let(:event) do 
          JSON.parse("#{file_fixture("/stripe_api/webhooks/payment_intents/unsuccessful_status_amount_payment_failed.json").read}")
        end
        let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
        let(:params) { event }
        let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS"] }

        it "should respond with a success status code" do
          do_request(params: params, headers: headers)

          expect(response).to be_successful
        end
        # TODO: should also probably do something else on our side...
      end

      context "bad request" do 
        let(:event) do 
          JSON.parse("#{file_fixture("/stripe_api/webhooks/payment_intents/unsuccessful_status_bad_request.json").read}")
        end
        let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
        let(:params) { event }
        let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS"] }

        it "should respond with a success status code" do
          do_request(params: params, headers: headers)

          expect(response.code).to eq("400")
        end
        # TODO: should also probably do something else on our side...
      end
    end
  end
end
