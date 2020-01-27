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
        before do
          allow(Bookings::SendNewBookingEmailsJob).to receive(:perform_in)
          allow(Bookings::UpdateSuccessfulPaymentJob).to receive(:perform_in)
        end

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
          # TODO: not anymore: the payment will be created in the bookings controller - we just update its status here
          pending 'great rush job late jan 2020'
          expect { do_request(params: params, headers: headers) }.to change { Payment.count }.by(1)
          expect(Payment.last.amount).to eq 90_000 # from successful_status_without_booking_id.json
          expect(Payment.last.success?).to eq true
        end

        it "should send out the new booking emails to the guest and guide" do
          # "We are now allowing time for the booking to be created - so just check the job is run"
          do_request(params: params, headers: headers)
          expect(Bookings::SendNewBookingEmailsJob).to have_received(:perform_in)
        end

        it "should call Bookings::UpdateSuccessfulPaymentJob" do
          # "We are now allowing time for the booking to be created - so just check the job is run"
          do_request(params: params, headers: headers)
          expect(Bookings::UpdateSuccessfulPaymentJob).to have_received(:perform_in)

          # TODO:
          #.with(correct_params)
          # time_to_allow_for_booking_creation,
          # amount_received,
          # stripe_payment_intent_id
        end
      end

      context "payment_intent.succeeded event - with pre-existing booking" do
        let!(:booking) { FactoryBot.create(:booking, id: "2f2a2255-8b43-4574-9d33-b7f56d624026") } # from: successful_status_with_booking_id
        let(:event) do 
          JSON.parse("#{file_fixture("/stripe_api/webhooks/payment_intents/successful_status_with_booking_id.json").read}")
        end
        let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
        let(:params) { event }
        let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS"] }

        it "should respond with a success status code" do
          pending 'great rush job late jan 2020'
          do_request(params: params, headers: headers)

          expect(response).to be_successful
        end

        it "should create a new payment associated with this booking" do
          pending 'great rush job late jan 2020'
          do_request(params: params, headers: headers)

          expect(booking.payments.count).to eq 1
          expect(booking.payments.first.amount).to eq 90_000 # from payment_intent_successful_status_with_booking_id.json
          expect(booking.payments.first.success?).to eq true
        end

        it "should send out the new booking emails to the guest and guide" do
          pending 'great rush job late jan 2020'
          expect { do_request(params: params, headers: headers) }.to change { ActionMailer::Base.deliveries.count }.by(2)
        end
      end

      context "payment already existed, (occurs when the webhook comes back AFTER the booking controller has created payment)" do
        # TODO: and also when payment existed but payment intent failed in webhook...
        it "should update the payment's status" do
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
        context "with pre-existing booking" do
          let!(:booking) { FactoryBot.create(:booking, id: "a90ce8e2-9af8-4b79-9035-b48390884565") } # from: unsuccessful_status_amount_payment_failed.json
          let(:event) do
            JSON.parse("#{file_fixture("/stripe_api/webhooks/payment_intents/unsuccessful_status_amount_payment_failed_with_booking_id.json").read}")
          end
          let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
          let(:params) { event }
          let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS"] }

          it "should respond with a success status code" do
            do_request(params: params, headers: headers)

            expect(response).to be_successful
          end

          it "should send the failed payment emails" do
            expect { do_request(params: params, headers: headers) }.to change { ActionMailer::Base.deliveries.count }.by(2)
            expect(ActionMailer::Base.deliveries.last.subject.include?("Outstanding Payment Failed"))
          end

          it "should create a charge with a failed status" do
            do_request(params: params, headers: headers)

            expect(booking.last_payment_failed?).to eq true
          end
        end

        context "without pre-existing booking" do
          before do
            allow(Bookings::SendFailedPaymentEmailsJob).to receive(:perform_in)
          end

          let(:event) do
            JSON.parse("#{file_fixture("/stripe_api/webhooks/payment_intents/unsuccessful_status_amount_payment_failed_without_booking_id.json").read}")
          end
          let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
          let(:params) { event }
          let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS"] }

          it "should respond with a success status code" do
            do_request(params: params, headers: headers)

            expect(response).to be_successful
          end

          it "should send out the failed payment emails to the guest and guide" do
            # "We are now allowing time for the booking to be created - so just check the job is run"
            do_request(params: params, headers: headers)
            expect(Bookings::SendFailedPaymentEmailsJob).to have_received(:perform_in)
          end
        end

        context "with a failed in_session SCA attempt" do
          let(:event) do
            JSON.parse("#{file_fixture("/stripe_api/webhooks/payment_intents/unsuccessful_status_payment_failed_in_session_payment_intent.json").read}")
          end
          let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
          let(:params) { event }
          let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS"] }

          it "should respond with a success status code (and not throw an app error)" do
            do_request(params: params, headers: headers)

            expect(response).to be_successful
          end

          it "should create a payment with a failed status" do
            expect { do_request(params: params, headers: headers) }.to change { Payment.count }.from(0).to(1)

            expect(Payment.last.failed?).to eq true
          end
        end
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
