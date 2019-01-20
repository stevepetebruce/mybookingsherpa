module External
  # Encapsulates all Stripe API functionality
  # Ref: https://stripe.com/docs/charges
  class StripeApi
    def initialize(amount:, currency:, description:, token:)
      @amount = amount
      @currency = currency
      @description = description
      @token = token
    end

    def charge
      initialize_api_key
      Stripe::Charge.create(attributes)
    end

    private

    def attributes
      {
        amount: @amount,
        currency: @currency,
        description: @description,
        source: @token
      }
    end

    def initialize_api_key
      Stripe.api_key ||= ENV.fetch("STRIPE_SECRET_KEY")
    end
  end
end
