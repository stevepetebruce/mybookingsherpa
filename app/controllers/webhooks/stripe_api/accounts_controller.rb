module Webhooks
  module StripeApi
    class AccountsController < ApplicationController
      include Onboardings::Tracking

      protect_from_forgery except: :create

      def create
        if organisation && !organisation.onboarding.complete?
          organisation.onboarding.update(stripe_account_complete: stripe_account_complete?)
          onboarding_complete_jobs if organisation.onboarding.reload.complete?
        end

        head :ok
      end

      private

      def end_point_secret
        ENV.fetch("STRIPE_WEBBOOK_SECRET_CONNECT_ACCOUNTS")
      end

      def event
        @event ||= Stripe::Webhook.construct_event(payload, signature_header, end_point_secret)
      end

      def onboarding_complete_jobs
        track_onboarding_event("trial_ended")
        Onboardings::DestroyTrialGuestsJob.perform_later(organisation)
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
        stripe_account_object.charges_enabled && stripe_account_object.payouts_enabled
      end

      def stripe_account_id
        stripe_account_object&.id
      end

      def stripe_account_object
        @stripe_account_object ||= event.data.object
      end
    end
  end
end
