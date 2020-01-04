module Bookings
  # Determines what params to use in the creation of Stripe PaymentIntents API
  class PaymentIntents
    MINIMUM_APPLICATION_FEE = 200 # £/€/$2

    def initialize(booking, payment_method = nil)
      @booking = booking
      @payment_method = payment_method
    end

    # TODO: delete and only use find_or_create ?
    def create
      # 1) with connected account id:

      if @booking.only_paying_deposit?
        External::StripeApi::PaymentIntent.create(attributes, use_test_api: use_test_api?)
      else
        External::StripeApi::PaymentIntent.create(attributes,
                                                  @booking.organisation_stripe_account_id,
                                                  use_test_api: use_test_api?)
      end
    end

    # TODO: delete and only use find_or_create ?
    def self.create(booking)
      new(booking).create
    end

    def find_or_create(stripe_payment_intent_id)
      if last_failed_payment_intent_id
        External::StripeApi::PaymentIntent.retrieve(last_failed_payment_intent_id,
                                                    @booking.organisation_stripe_account_id,
                                                    use_test_api: use_test_api?)
      elsif stripe_payment_intent_id && @booking.only_paying_deposit?
        External::StripeApi::PaymentIntent.retrieve(stripe_payment_intent_id,
                                                    use_test_api: use_test_api?)
      elsif stripe_payment_intent_id
        External::StripeApi::PaymentIntent.retrieve(stripe_payment_intent_id,
                                                    @booking.organisation_stripe_account_id,
                                                    use_test_api: use_test_api?)
      else
        create
      end
    end

    def find_or_create_two
      External::StripeApi::PaymentIntent.create(attributes_two,
                                                @booking.organisation_stripe_account_id,
                                                use_test_api: use_test_api?)
    end

    def self.find_or_create(booking, stripe_payment_intent_id = nil)
      new(booking).find_or_create(stripe_payment_intent_id)
    end

    def self.find_or_create_two(booking, payment_method)
      new(booking, payment_method).find_or_create_two
    end

    private

    def amount_due
      @amount_due ||= Bookings::CostCalculator.new(@booking).amount_due
    end

    def application_fee
      return 0 if @booking.only_paying_deposit?

      [calculated_application_fee, MINIMUM_APPLICATION_FEE].max
    end

    # When paying initial/full amount (in one go)
    # def attributes
    #   {
    #     amount: amount_due,
    #     application_fee_amount: application_fee,
    #     currency: @booking.currency,
    #     customer: @booking.stripe_customer_id,
    #     setup_future_usage: setup_future_usage,
    #     statement_descriptor_suffix: statement_descriptor_suffix,
    #     transfer_data: transfer_data
    #   }.reject { |_k, v| v == 0 }
    # end

    def attributes
      {
        amount: amount_due,
        application_fee_amount: application_fee,
        currency: @booking.currency,
        customer: @booking.stripe_customer_id,
        payment_method_types: ["card"],
        setup_future_usage: setup_future_usage,
        statement_descriptor_suffix: statement_descriptor_suffix,
        # transfer_data: transfer_data
      }.reject { |_k, v| v == 0 }
    end

    def attributes_two
      {
        amount: amount_due,
        application_fee_amount: application_fee,
        currency: @booking.currency,
        customer: @booking.stripe_customer_id,
        payment_method: @payment_method,
        payment_method_types: ["card"],
        setup_future_usage: setup_future_usage,
        statement_descriptor_suffix: statement_descriptor_suffix,
        # transfer_data: transfer_data
      }.reject { |_k, v| v == 0 }.compact
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

    # def transfer_data
    #   # TODO: don't we need the amount to be paid to the guide account here too?
    #   {
    #     destination: @booking.organisation_stripe_account_id
    #   }
    # end

    def setup_future_usage
      @booking.only_paying_deposit? ? "off_session" : "on_session"
    end

    def use_test_api?
      @booking.organisation_on_trial?
    end
  end
end
