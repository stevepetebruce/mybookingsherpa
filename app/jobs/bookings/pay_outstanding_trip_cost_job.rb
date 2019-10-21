module Bookings
  # ref: https://stripe.com/docs/payments/cards/charging-saved-cards#create-payment-intent-off-session
  class PayOutstandingTripCostJob < ApplicationJob
    queue_as :default

    def perform(booking)
      @booking = booking

      return unless full_payment_required?

      # TODO: refactor this so it uses Bookings::PaymentIntents.create(@booking)
      External::StripeApi::PaymentIntent.create(attributes, use_test_api: use_test_api?)
    end

    private

    def amount_due
      @amount_due ||= Bookings::CostCalculator.new(@booking).amount_due
    end

    def attributes
      {
        amount: amount_due,
        # TODO: application_fee_amount: application_fee_amount,
        confirm: true,
        currency: @booking.currency,
        customer: @booking.stripe_customer_id,
        metadata: { booking_id:  @booking.id },
        off_session: true,
        payment_method: stripe_payment_method_id,
        statement_descriptor: charge_description
      }
    end

    def charge_description
      @booking.trip_name.truncate(22, separator: " ")
    end

    def full_payment_required?
      Bookings::PaymentStatus.new(@booking).payment_required?
    end

    def stripe_payment_method_id
      @stripe_payment_method_id ||=
        External::StripeApi::PaymentMethod.list(@booking.stripe_customer_id)&.first&.id
    end

    def use_test_api?
      @booking.organisation_on_trial?
    end
  end
end
