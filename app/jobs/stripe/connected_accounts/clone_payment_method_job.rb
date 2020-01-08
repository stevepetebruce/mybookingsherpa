module Stripe
  module ConnectedAccounts
    class ClonePaymentMethodJob
      include Sidekiq::Worker

      def perform(account_id, payment_method_id, setup_intent_id, use_test_api = true)
        #TODO: What about existing customers?  External::StripeApi::Customer.find_or_create ?
        customer = External::StripeApi::Customer.create(payment_method: payment_method_id,
                                                        use_test_api: use_test_api)

        cloned_payment_method = External::StripeApi::PaymentMethod.clone(account: account_id,
                                                                         customer: customer.id,
                                                                         payment_method: payment_method_id,
                                                                         use_test_api: use_test_api)

        # TODO: try replacing the above with this line:
        #  and then use the connected_customer in attach_payment_method_and_customer_to_booking
        connected_customer = Stripe::Customer.create({ payment_method: cloned_payment_method }, stripe_account: account_id)

        puts 'customer    ' + customer.inspect
        puts ' - - - -- - '
        puts 'connected_customer    ' + connected_customer.inspect

        puts ' - - -- - - '
        puts 'payment_method_id  ' + payment_method_id.inspect
        puts ' - - - - -- - - - -- '
        puts 'cloned_payment_method ' + cloned_payment_method.inspect

        attach_payment_method_and_customer_to_booking(cloned_payment_method.id, connected_customer.id, setup_intent_id)
      end

      private

      def attach_payment_method_and_customer_to_booking(cloned_payment_method_id, customer_id, setup_intent_id)
        Bookings::AttachStripePaymentMethodAndCustomerJob.perform_in(time_to_allow_for_booking_creation,
                                                                     cloned_payment_method_id,
                                                                     customer_id,
                                                                     setup_intent_id)
      end

      def time_to_allow_for_booking_creation
        # TODO: rename this env var
        ENV.fetch("BOOKING_EMAILS_SENDING_DELAY", "1").to_i.minutes
      end
    end
  end
end
