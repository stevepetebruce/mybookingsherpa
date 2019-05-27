module Bookings
  # Handles all bookings' payment business logic.
  class Payment
    MINIMUM_FREE_TRIP_COST = 20_000
    DESTINATION_FEE = 400

    def initialize(booking, token)
      @booking = booking
      @token = token
    end

    def charge
      raise NoOrganisationStripeAccountIdError if @booking.organisation_stripe_account_id.nil?
      External::StripeApi::Charge.create(attributes)
    end

    private

    def amount_due
      @amount_due ||= Bookings::CostCalculator.new(@booking).amount_due
    end

    def application_fee_amount
      # TODO: DESTINATION_FEE is currently €4. But need to calculate this from the plan the @booking.organisation is on
      @booking.full_cost > MINIMUM_FREE_TRIP_COST ? DESTINATION_FEE : 0
    end

    def attributes
      {
        amount: amount_due,
        application_fee_amount: application_fee_amount,
        currency: @booking.currency,
        description: charge_description,
        use_test_api: @booking.organisation_on_trial?,
        transfer_data: transfer_data,
        token: @token
      }
    end

    def charge_description
      "#{Currency.iso_to_symbol(@booking.currency)}" \
        "#{Currency.human_readable(amount_due)} " \
        "paid to #{@booking.organisation_name} for #{@booking.trip_name}"
    end

    def transfer_data
      {
        destination: @booking.organisation_stripe_account_id
      }
    end
  end
end
