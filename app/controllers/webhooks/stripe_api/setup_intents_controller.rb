module Webhooks
  module StripeApi
    class SetupIntentsController < ApplicationController
      protect_from_forgery except: :create

      def create
        handle_event
      rescue JSON::ParserError, Stripe::SignatureVerificationError => e
        # TODO: log e ? / throw error so that Rollbar etc catches it?
        head :bad_request and return
      end

      private

      def booking
        return if setup_intent.metadata.as_json.dig("booking_id").nil?

        @booking ||= Booking.find(setup_intent.metadata.booking_id)
      end

      def end_point_secret
        ENV.fetch("STRIPE_WEBBOOK_SECRET_SETUP_INTENTS")
      end

      def event
        @event ||= Stripe::Webhook.construct_event(payload, signature_header, end_point_secret)
      end

      def handle_event
        case event.type
        when "setup_intent.succeeded"
          Stripe::ConnectedAccounts::ClonePaymentMethodAndCustomerJob.
            perform_async(stripe_account_id,
                          setup_intent.payment_method,
                          setup_intent.id,
                          use_test_api?)
                                                             
          Bookings::PayInitialCostJob.perform_in(time_to_allow_for_other_job_to_run, setup_intent.id)
        when "setup_intent.setup_failed"
          # TODO:
          # payment.update(amount: amount, status: "failed")
          # send_failed_payment_emails if payment_failure_message #TODO: this is a little fragile: assumes there's no charge objects in a failed on_session payment_intent
        else
          # TODO: Email guest and guide...?
          head :bad_request and return
        end

        head :ok
      end

      def payload
        request.body.read
      end

      def setup_intent
        @setup_intent ||= event.data.object
      end

      def signature_header
        request.env["HTTP_STRIPE_SIGNATURE"]
      end

      def stripe_account_id
        @stripe_account_id ||= setup_intent.metadata.as_json.dig("stripe_account_id")
      end

      def time_to_allow_for_other_job_to_run
        # TODO: rename this env var.... 
        (ENV.fetch("BOOKING_EMAILS_SENDING_DELAY", "1").to_i * 2).minutes
      end

      def use_test_api?
        setup_intent.metadata.as_json.dig("use_test_api")
      end
    end
  end
end
