module External
  module StripeApi
    # Encapsulates all common Stripe API functionality
    class Base
      def initialize_key # TODO: replace with initialize ?
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
end
