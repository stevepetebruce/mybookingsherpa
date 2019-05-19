module External
  # Encapsulates all Stripe API functionality
  # Ref: https://stripe.com/docs/charges
  class StripeApi
    def initialize(amount:, application_fee_amount:, currency:, description:, transfer_data:, token:, use_test_api:)
      @amount = amount
      @application_fee_amount = application_fee_amount
      @currency = currency
      @description = description
      @transfer_data = transfer_data
      @token = token
      @use_test_api = use_test_api
    end

    def charge
      initialize_key
      Stripe::Charge.create(attributes)
    end

    private

    def attributes
      {
        amount: @amount,
        application_fee_amount: @application_fee_amount,
        currency: @currency,
        description: @description,
        source: @token,
        transfer_data: @transfer_data
      }
    end

    def initialize_key
      Stripe.api_key = stripe_secret_key
    end

    def stripe_secret_key
      if @use_test_api
        ENV.fetch("STRIPE_SECRET_KEY_TEST")
      else
        ENV.fetch("STRIPE_SECRET_KEY_LIVE")
      end
    end
  end
end
