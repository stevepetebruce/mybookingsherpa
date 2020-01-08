module Bookings
  # ref: https://stripe.com/docs/payments/cards/charging-saved-cards#create-payment-intent-off-session
  class PayOutstandingTripCostJob
    include Sidekiq::Worker
    sidekiq_options queue: :default, retry: 0

    # MINIMUM_APPLICATION_FEE = 200 # £/€/$2

    def perform(booking_id)
      @booking = Booking.find(booking_id)

      # TODO: look at this... this job fails when in trial: return if @booking.organisation_on_trial?
      return unless full_payment_required?

      Bookings::PaymentIntents.create(@booking)
    end

    private

    # def amount_due
    #   @amount_due ||= Bookings::CostCalculator.new(@booking).amount_due
    # end

    # def application_fee
    #   [calculated_application_fee, MINIMUM_APPLICATION_FEE].max
    # end

    # def attributes
    #   {
    #     amount: amount_due,
    #     application_fee_amount: application_fee,
    #     confirm: true,
    #     currency: @booking.currency,
    #     customer: @booking.stripe_customer_id,
    #     metadata: { booking_id: @booking.id },
    #     off_session: true,
    #     payment_method: stripe_payment_method_id,
    #     statement_descriptor_suffix: statement_descriptor_suffix,
    #     transfer_data: transfer_data
    #   }
    # end

    # # TODO: write a spec to cover using the MINIMUM_APPLICATION_FEE
    # def calculated_application_fee
    #   (@booking.full_cost * @booking.organisation_plan.percentage_amount).to_i # TODO: if we ever use flat_fee plans, need to change here.
    # end

    # def statement_descriptor_suffix
    #   @booking.trip_name.truncate(22, separator: " ")
    # end

    def full_payment_required?
      # TODO: check this... once we create the payment - even if it the payment_intent fails
      #  this will return false, when it totals up all the payments' amounts associated with
      #  this booking...
      Bookings::PaymentStatus.new(@booking).payment_required?
    end

    # def stripe_payment_method
    #   @stripe_payment_method ||=
    #     External::StripeApi::PaymentMethod.list(@booking.stripe_customer_id,
    #                                             use_test_api: use_test_api?)
    # end

    # def stripe_payment_method_id
    #   stripe_payment_method&.first&.id
    # end

    # def transfer_data
    #   {
    #     destination: @booking.organisation_stripe_account_id
    #   }
    # end

    # def use_test_api?
    #   @booking.organisation_on_trial?
    # end
  end
end
