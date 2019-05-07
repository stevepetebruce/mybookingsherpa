module External
  # Encapsulates all Stripe API functionality
  # Ref: https://stripe.com/docs/charges
  class StripeApi
    def initialize(amount:, application_fee_amount:, currency:, description:, transfer_data:, token:)
      @amount = amount
      @application_fee_amount = application_fee_amount
      @currency = currency
      @description = description
      @transfer_data = transfer_data
      @token = token
      Stripe.api_key ||= ENV.fetch("STRIPE_SECRET_KEY")
    end

    def charge
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
  end
end
