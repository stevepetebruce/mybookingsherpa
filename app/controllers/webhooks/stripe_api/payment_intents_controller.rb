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
          update(amount: amount_received)
      end

      def create_or_update_payment
        Payment.where(stripe_payment_intent_id: stripe_payment_intent_id).
          first_or_create.
          update(amount: amount_received)
      end

      def end_point_secret
        ENV.fetch("STRIPE_WEBBOOK_SECRET_PAYMENT_INTENTS")
      end

      def event
        @event ||= Stripe::Webhook.construct_event(payload, signature_header, end_point_secret)
      end

      def handle_event
        # TODO: on success: capture payment:
        # https://stripe.com/docs/api/payment_intents/capture
        # https://stripe.com/docs/payments/intents#intent-statuses
        case event.type
        when "payment_intent.amount_capturable_updated"
          # TODO: need confirmation? etc...
        when "payment_intent.succeeded"
          update_or_create_payment
        when "payment_intent.payment_failed"
          # TODO: Email guest and guide...?
        else
          # TODO: Email guest and guide...?
          head :bad_request and return
        end

        head :ok
      end

      def payload
        request.body.read
      end

      def payment_intent
        @payment_intent ||= event.data.object
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
      end
    end
  end
end
