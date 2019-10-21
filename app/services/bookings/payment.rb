module Bookings
  # Handles all bookings' payment business logic.
  class Payment
    MINIMUM_LOWER_TRIP_COST = 20_000 # €200
    MINIMUM_DESTINATION_FEE = 200 # €2
    REGULAR_DESTINATION_FEE = 400 # €4

    def initialize(booking)
      @booking = booking
    end

    def amount_due
      @amount_due ||= Bookings::CostCalculator.new(@booking).amount_due
    end

    def charge
      raise NoOrganisationStripeAccountIdError if @booking.organisation_stripe_account_id.nil?
      External::StripeApi::Charge.create(attributes)
    end

    private

    def application_fee_amount
      return 0 if paying_deposit?

      below_minimum_trip_cost? ? MINIMUM_DESTINATION_FEE : REGULAR_DESTINATION_FEE
    end

    def attributes
      {
        amount: amount_due,
        application_fee_amount: application_fee_amount,
        currency: @booking.currency,
        customer: @booking.stripe_customer_id,
        description: charge_description,
        use_test_api: @booking.organisation_on_trial?,
        transfer_data: transfer_data
      }
    end

    def below_minimum_trip_cost?
      @booking.full_cost <= MINIMUM_LOWER_TRIP_COST
    end

    def charge_description
      "#{Currency.iso_to_symbol(@booking.currency)}" \
        "#{Currency.human_readable(amount_due)} " \
        "#{'(deposit) ' if paying_deposit? }" \
        "paid to #{@booking.organisation_name} for #{@booking.trip_name}"
    end

    def transfer_data
      {
        destination: @booking.organisation_stripe_account_id
      }
    end

    def paying_deposit?
      amount_due == @booking.deposit_cost
    end
  end
end
