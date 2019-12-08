module Bookings
  # Determines what params to use in the creation of Stripe PaymentIntents API
  class PaymentIntents
    MINIMUM_APPLICATION_FEE = 200 # £/€/$2

    def initialize(booking)
      @booking = booking
    end

    # TODO: delete and only use find_or_create ?
    def create
      External::StripeApi::PaymentIntent.create(attributes, use_test_api: use_test_api?)
    end

    # TODO: delete and only use find_or_create ?
    def self.create(booking)
      new(booking).create
    end

    def find_or_create
      if last_failed_payment_intent_id
        External::StripeApi::PaymentIntent.retrieve(last_failed_payment_intent_id,
                                                    use_test_api: use_test_api?)
      else
        create
      end
    end

    def self.find_or_create(booking)
      new(booking).find_or_create
    end

    private

    def amount_due
      @amount_due ||= Bookings::CostCalculator.new(@booking).amount_due
    end

    def application_fee
      [calculated_application_fee, MINIMUM_APPLICATION_FEE].max
    end

    # When paying initial/full amount (in one go)
    def attributes
      {
        amount: amount_due,
        application_fee_amount: application_fee,
        currency: @booking.currency,
        customer: @booking.stripe_customer_id,
        setup_future_usage: setup_future_usage,
        statement_descriptor: statement_descriptor,
        transfer_data: transfer_data
      }.reject { |_k, v| v == 0 }
    end

    def calculated_application_fee
      (amount_due * @booking.organisation_plan.percentage_amount).to_i # TODO: if we ever use flat_fee plans, need to change here.
    end

    def last_failed_payment_intent_id
      @booking&.last_failed_payment&.stripe_payment_intent_id
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
