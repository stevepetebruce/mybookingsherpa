module Bookings
  # Retreives either existing stripe_customer_id or a new one from Stripe API
  class StripeCustomer
    def initialize(booking, payment_method)
      @booking = booking
      @payment_method = payment_method
    end

    def id
      return new_customer.id if create_new_stripe_customer?

      @booking.stripe_customer_id
    end

    private

    def attributes
      {
        description: @booking.guest_email,
        payment_method: @payment_method
      }
    end

    def create_new_stripe_customer?
      @booking.stripe_customer_id.nil? ||
        customer_does_not_exist_in_stripe? ||
        customer_deleted_in_stripe?
    end

    def customer_deleted_in_stripe?
      retrieved_customer.deleted?
    end

    def customer_does_not_exist_in_stripe?
      !customer_exists_in_stripe?
    end

    def customer_exists_in_stripe?
      return true if retrieved_customer.present?
    rescue Stripe::InvalidRequestError
      false
    end

    def new_customer
      External::StripeApi::Customer.create(attributes,
                                           stripe_account: @booking.organisation_stripe_account_id,
                                           use_test_api: @booking.organisation_on_trial?)
    end

    def retrieved_customer
      @retrieved_customer ||=
        External::StripeApi::Customer.retrieve(customer_id: @booking.stripe_customer_id,
                                               use_test_api: @booking.organisation_on_trial?)
    end
  end
end
