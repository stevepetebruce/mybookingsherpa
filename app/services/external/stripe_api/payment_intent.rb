module External
  module StripeApi
    # ref: https://stripe.com/docs/payments/payment-intents/web
    # https://stripe.com/docs/api/payment_intents
    class PaymentIntent < External::StripeApi::Base
      def initialize(use_test_api)
        @use_test_api = use_test_api
        initialize_key # TODO: replace with super?
      end

      # def create(attributes, stripe_account)
      #   return if amount_zero?(attributes)

      #   puts '!!!!! - - - - !!!'
      #   puts 'sanitized_attributes(attributes) ' + sanitized_attributes(attributes).inspect
      #   puts 'stripe_account ' + stripe_account.inspect

      #   res = Stripe::PaymentIntent.create(sanitized_attributes(attributes),
      #                                stripe_account: stripe_account)
      #   puts 'res ' + res.inspect
      #   res
      # end

      def create(attributes, stripe_account)
        return if amount_zero?(attributes)

        puts '!!!!! PaymentIntent  - - - - !!!'
        puts 'sanitized_attributes(attributes) ' + sanitized_attributes(attributes).inspect
        puts 'stripe_account ' + stripe_account.inspect
        if stripe_account
          puts '!!! - with stripe connected account'
          res = Stripe::PaymentIntent.create(sanitized_attributes(attributes), stripe_account: stripe_account) 
        else
          puts '!!! - without stripe connected account'
          res = Stripe::PaymentIntent.create(sanitized_attributes(attributes))
        end
        puts 'res ' + res.inspect
        res
      end

      def retrieve(payment_intent_id, stripe_account)
        if stripe_account
          Stripe::PaymentIntent.retrieve(payment_intent_id, stripe_account: stripe_account)
        else
          Stripe::PaymentIntent.retrieve(payment_intent_id)
        end
      end

      # def self.create(attributes, stripe_account, use_test_api: true)
      #   new(use_test_api).create(attributes, stripe_account)
      # end

      def self.create(attributes, stripe_account = nil, use_test_api: true)
        new(use_test_api).create(attributes, stripe_account)
      end

      def self.retrieve(payment_intent_id, stripe_account = nil, use_test_api: true)
        new(use_test_api).retrieve(payment_intent_id, stripe_account)
      end

      private

      def amount_zero?(attributes)
        sanitized_attributes(attributes)[:amount].zero?
      end

      def sanitized_attributes(attributes)
        attributes.map do |k, v|
          if k == :statement_descriptor_suffix
            [k, v.gsub(/[^a-zA-Z0-9\s\\.]/, "_")]
          else
            [k, v]
          end
        end.to_h
      end
    end
  end
end
