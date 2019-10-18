module Bookings
  # Handles all bookings' payment business logic.
  # TODO: this should be in the PaymentIntents class...
  # Move all this over to PaymentIntents
  class Payment
    MINIMUM_LOWER_TRIP_COST = 20_000 # €200
    MINIMUM_DESTINATION_FEE = 200 # €2
    REGULAR_DESTINATION_FEE = 400 # €4

    # def initialize(booking)
    #   @booking = booking
    # end

    # def amount_due
    #   @amount_due ||= Bookings::CostCalculator.new(@booking).amount_due
    # end

    def charge
      raise NoOrganisationStripeAccountIdError if !@booking.organisation_on_trial? &&
        @booking.organisation_stripe_account_id.nil?

      External::StripeApi::PaymentIntent.create(attributes, use_test_api: use_test_api?)
    end

    private

    # def application_fee_amount
    #   return 0 if paying_deposit?

    #   below_minimum_trip_cost? ? MINIMUM_DESTINATION_FEE : REGULAR_DESTINATION_FEE
    # end

    # def attributes
    #   {
    #     amount: amount_due,
    #     confirm: true,
    #     currency: @booking.currency,
    #     customer: @booking.stripe_customer_id,
    #     metadata: { booking_id:  @booking.id },
    #     off_session: true,
    #     payment_method: stripe_payment_method_id,
    #     statement_descriptor: charge_description
    #   }
    # end

    # def below_minimum_trip_cost?
    #   @booking.full_cost <= MINIMUM_LOWER_TRIP_COST
    # end

    # def charge_description
    #   @booking.trip_name.truncate(22, separator: " ")
    # end

    # def stripe_payment_method_id
    #   @stripe_payment_method_id ||=
    #     External::StripeApi::PaymentMethod.list(@booking.stripe_customer_id)&.first&.id
    # end

    # def transfer_data
    #   {
    #     destination: @booking.organisation_stripe_account_id
    #   }
    # end

    # def paying_deposit?
    #   amount_due == @booking.deposit_cost
    # end

    # def use_test_api?
    #   @booking.organisation_on_trial?
    # end
  end
end
