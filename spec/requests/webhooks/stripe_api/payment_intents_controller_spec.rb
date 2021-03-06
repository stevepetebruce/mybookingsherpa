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
        end

        let(:amount_received) { 90_000 } # from successful_status_without_booking_id.json
        let!(:event) do
          FactoryBot.create(:stripe_event,
                            json: JSON.parse("#{file_fixture("/stripe_api/webhooks/payment_intents/successful_status_without_booking_id.json").read}"))
        end
        let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
        let(:params) { event }
        let!(:payment) { FactoryBot.create(:payment, :pending, stripe_payment_intent_id: "pi_1FVH25ESypPNvvdYGDo6X9H1") }
        let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS"] }
        let(:stripe_payment_intent_id) { "pi_1FVH25ESypPNvvdYGDo6X9H1" }
        let(:time_to_allow_for_booking_creation) { ENV.fetch("BOOKING_EMAILS_SENDING_DELAY", "1").to_i.minutes }

        it "should respond with a success status code" do
          do_request(params: params, headers: headers)

          expect(response).to be_successful
        end

        it "should update the payment" do
          do_request(params: params, headers: headers)

          expect(payment.reload.amount).to eq 90_000 # from successful_status_without_booking_id.json
          expect(payment.success?).to eq true
        end

        it "should send out the new booking emails to the guest and guide" do
          # "We are now allowing time for the booking to be created - so just check the job is run"
          do_request(params: params, headers: headers)
          expect(Bookings::SendNewBookingEmailsJob).to have_received(:perform_in)
        end

        it "should call Bookings::UpdateSuccessfulPaymentJob" do
          allow(Bookings::UpdateSuccessfulPaymentJob).to receive(:perform_in)
          # "We are now allowing time for the booking to be created - so just check the job is run"
          do_request(params: params, headers: headers)
          expect(Bookings::UpdateSuccessfulPaymentJob).
            to have_received(:perform_in).
            with(time_to_allow_for_booking_creation, amount_received, stripe_payment_intent_id)
        end
      end

      context "payment_intent.succeeded event - with pre-existing booking" do
        let!(:booking) { FactoryBot.create(:booking, id: "2f2a2255-8b43-4574-9d33-b7f56d624026") } # from: successful_status_with_booking_id
        let!(:event) do
          FactoryBot.create(:stripe_event,
                            meant_for_this_environment: true,
                            json: JSON.parse("#{file_fixture("/stripe_api/webhooks/payment_intents/successful_status_with_booking_id.json").read}"))
        end
        let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
        let(:params) { event }
        let!(:payment) { FactoryBot.create(:payment, :pending, booking: booking, stripe_payment_intent_id: "pi_1FVH25ESypPNvvdYGDo6X9H1") }
        let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS"] }

        before do
          @queue_adapter = ActiveJob::Base.queue_adapter
          (ActiveJob::Base.descendants << ActiveJob::Base).each(&:disable_test_adapter)
        end

        after do
          (ActiveJob::Base.descendants << ActiveJob::Base).each { |job| job.enable_test_adapter(@queue_adapter) }
        end

        it "should respond with a success status code" do
          do_request(params: params, headers: headers)

          expect(response).to be_successful
        end

        it "should update the payment associated with this booking" do
          do_request(params: params, headers: headers)

          expect(booking.payments.first.amount).to eq 90_000 # from payment_intent_successful_status_with_booking_id.json
          expect(booking.payments.first.success?).to eq true
        end

        it "should send out the new booking emails to the guest and guide" do
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
            FactoryBot.create(:stripe_event,
                              json: JSON.parse("#{file_fixture("/stripe_api/webhooks/payment_intents/unsuccessful_status_amount_payment_failed_with_booking_id.json").read}"))
          end
          let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
          let(:params) { event }
          let!(:payment) { FactoryBot.create(:payment, :pending, booking: booking, stripe_payment_intent_id: "pi_1FlQxUESypPNvvdYM2c3ClZd") }
          let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS"] }

          before do
            @queue_adapter = ActiveJob::Base.queue_adapter
            (ActiveJob::Base.descendants << ActiveJob::Base).each(&:disable_test_adapter)
          end

          after do
            (ActiveJob::Base.descendants << ActiveJob::Base).each { |job| job.enable_test_adapter(@queue_adapter) }
          end

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
      end

      context "bad request" do 
        let(:event) do
          FactoryBot.create(:stripe_event,
                            json: JSON.parse("#{file_fixture("/stripe_api/webhooks/payment_intents/unsuccessful_status_bad_request.json").read}"))
        end
        let(:headers) { { "Stripe-Signature" => stripe_event_signature(event.to_json, secret) } }
        let(:params) { event }
        let(:secret) { ENV["STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS"] }

        it "should respond with a bad status code" do
          do_request(params: params, headers: headers)

          expect(response.code).to eq("400")
        end
        # TODO: should also probably do something else on our side...
      end

      context "not_meant_for_this_environment = true" do
        # TODO: Need to test this...
      end
    end
  end
end
