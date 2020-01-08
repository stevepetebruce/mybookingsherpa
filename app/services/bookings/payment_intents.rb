module Bookings
  # Determines what params to use in the creation of Stripe PaymentIntents API
  class PaymentIntents
    MINIMUM_APPLICATION_FEE = 200 # £/€/$2

    def initialize(booking)
      @booking = booking
    end

    # TODO: delete and only use find_or_create ?
    def create
      External::StripeApi::PaymentIntent.create(attributes, @booking.organisation_stripe_account_id, use_test_api: use_test_api?)
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
      return 0 if @booking.only_paying_deposit?

      [calculated_application_fee, MINIMUM_APPLICATION_FEE].max
    end

    def attributes
      {
        amount: amount_due,
        application_fee_amount: application_fee,
        confirm: true,
        currency: @booking.currency,
        customer: @booking.stripe_customer_id,
        metadata: { booking_id: @booking.id },
        off_session: true,
        payment_method: @booking.stripe_payment_method_id,
        statement_descriptor_suffix: statement_descriptor_suffix
      }.reject { |_k, v| v == 0 }
    end

    def calculated_application_fee
      (@booking.full_cost * @booking.organisation_plan.percentage_amount).to_i # TODO: if we ever use flat_fee plans, need to change here.
    end

    def last_failed_payment_intent_id
      @booking&.last_failed_payment&.stripe_payment_intent_id
    end

    def statement_descriptor_suffix
      @booking.trip_name.truncate(22, separator: " ")
    end

    def use_test_api?
      @booking.organisation_on_trial?
    end
  end
end
