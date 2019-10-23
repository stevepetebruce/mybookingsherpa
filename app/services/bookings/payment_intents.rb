module Bookings
  # Determines what params to use in the creation of Stripe PaymentIntents API
  class PaymentIntents
    MINIMUM_LOWER_TRIP_COST = 20_000 # €200
    MINIMUM_DESTINATION_FEE = 200 # €2
    REGULAR_DESTINATION_FEE = 400 # €4

    def initialize(booking)
      @booking = booking
    end

    def create
      External::StripeApi::PaymentIntent.create(attributes, use_test_api: use_test_api?)
    end

    def self.create(booking)
      new(booking).create
    end

    def self.find_or_create(booking)
      # TODO: retrieve booking's payment_intent if it has one...
      # This would be the case, for example, when there's been an error, and we need to show user feedback?
      # find || create
      self.create(booking)
    end

    private

    def amount_due
      @amount_due ||= Bookings::CostCalculator.new(@booking).amount_due
    end

    def application_fee_amount
      # TODO: need to add this in... and in PayOutstandingAmountJob....
      # ref:  https://stripe.com/docs/strong-customer-authentication/connect-platforms#step-3
      return 0 if paying_deposit?

      below_minimum_trip_cost? ? MINIMUM_DESTINATION_FEE : REGULAR_DESTINATION_FEE
    end

    # When paying initial/full amount (in one go)
    def attributes
      {
        amount: @booking.amount_due,
        application_fee_amount: application_fee_amount,
        currency: @booking.currency,
        customer: @booking.stripe_customer_id,
        setup_future_usage: setup_future_usage,
        statement_descriptor: statement_descriptor,
        transfer_data: transfer_data
      }.reject { |_k, v| v == 0 }
    end

    def below_minimum_trip_cost?
      @booking.full_cost <= MINIMUM_LOWER_TRIP_COST
    end

    def statement_descriptor
      @booking.trip_name.truncate(22, separator: " ")
    end

    def transfer_data
      # TODO: don't we need the amount to be paid to the guide account here too?
      {
        destination: @booking.organisation_stripe_account_id
      }
    end

    def paying_deposit?
      amount_due == @booking.deposit_cost
    end

    def setup_future_usage
      @booking.only_paying_deposit? ? "off_session" : "on_session"
    end

    def use_test_api?
      @booking.organisation_on_trial?
    end
  end
end
