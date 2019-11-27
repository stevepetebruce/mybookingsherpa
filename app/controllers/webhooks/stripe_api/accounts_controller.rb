module Webhooks
  module StripeApi
    class AccountsController < ApplicationController
      protect_from_forgery except: :create

      def create
        update_stripe_account_completion_status
        head :ok
      end

      private

      def end_point_secret
        ENV.fetch("STRIPE_WEBBOOK_SECRET_CONNECT_ACCOUNTS")
      end

      def event
        @event ||= Stripe::Webhook.construct_event(payload, signature_header, end_point_secret)
      end

      def organisation
        @organisation ||= Organisation.find_by_stripe_account_id_live(stripe_account_id)
      end

      def payload
        request.body.read
      end

      def signature_header
        request.env["HTTP_STRIPE_SIGNATURE"]
      end

      def stripe_account_complete?
        stripe_account_object&.charges_enabled
      end

      def stripe_account_id
        stripe_account_object&.id
      end

      def stripe_account_object
        @stripe_account_object ||= event.data.object
      end

      def update_stripe_account_completion_status
        # TODO: also need to make sure payouts_enabled
        organisation.onboarding.update(stripe_account_complete: stripe_account_complete?) if organisation
      end
    end
  end
end
