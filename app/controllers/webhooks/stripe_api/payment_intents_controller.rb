module Webhooks
  module StripeApi
    class PaymentIntentsController < ApplicationController
      protect_from_forgery except: :create

      def create
        handle_event
      rescue JSON::ParserError, Stripe::SignatureVerificationError => e
        # TODO: log e ? / throw error so that Rollbar etc catches it?
        head :bad_request and return
      end

      private

      def amount
        stripe_payment_intent.amount
      end

      def amount_received
        stripe_payment_intent.amount_received
      end

      def booking
        return if payment_intent.metadata.as_json.dig("booking_id").nil?

        @booking ||= Booking.find(@payment_intent.metadata.booking_id)
      end

      def create_or_update_booking_payment
        booking.payments.where(stripe_payment_intent_id: stripe_payment_intent_id).
          first_or_create.
          update(amount: amount_received, status: :success)
      end

      def create_or_update_payment
        Payment.where(stripe_payment_intent_id: stripe_payment_intent_id).
          first_or_create.
          update(amount: amount_received, status: :success)
      end

      def end_point_secret
        ENV.fetch("STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS")
      end

      def event
        @event ||= Stripe::Webhook.construct_event(payload, signature_header, end_point_secret)
      end

      def handle_event
        case event.type
        when "payment_intent.created"
        when "payment_intent.amount_capturable_updated"
        when "payment_intent.succeeded"
          update_or_create_payment
        when "payment_intent.payment_failed"
          payment.update(amount: amount, status: "failed")
          send_failed_payment_emails
        else
          # TODO: Email guest and guide...?
          head :bad_request and return
        end

        head :ok
      end

      def payload
        request.body.read
      end

      def payment
        if booking
          booking.payments.where(stripe_payment_intent_id: stripe_payment_intent_id).first_or_create
        else
          Payment.where(stripe_payment_intent_id: stripe_payment_intent_id).first_or_create
        end
      end

      def payment_failure_message
        event.data.object.charges.first.failure_message
      end

      def payment_intent
        @payment_intent ||= event.data.object
      end

      def send_failed_payment_emails
        Bookings::SendFailedPaymentEmailsJob.perform_in(time_to_allow_for_booking_creation,
                                                        stripe_payment_intent_id,
                                                        payment_failure_message)
      end

      def send_new_booking_payment_emails
        Bookings::SendNewBookingEmailsJob.perform_in(time_to_allow_for_booking_creation,
                                                     stripe_payment_intent_id)
      end

      def signature_header
        request.env["HTTP_STRIPE_SIGNATURE"]
      end

      def stripe_payment_intent
        @stripe_payment_intent ||= event.data.object
      end

      def stripe_payment_intent_id
        stripe_payment_intent.id
      end

      def update_or_create_payment
        # TODO: how to handle failures here?
        Payment.transaction do
          booking ? create_or_update_booking_payment : create_or_update_payment
        end
        send_new_booking_payment_emails
      end

      def time_to_allow_for_booking_creation
        15.minutes
      end
    end
  end
end
