module Bookings
  # Retreives either existing stripe_customer_id or a new one from Stripe API
  class StripeCustomer
    def initialize(booking, stripe_token)
      @booking = booking
      @stripe_token = stripe_token
    end

    def id
      return new_customer.id if create_new_stripe_customer?

      @booking.stripe_customer_id
    end

    private

    def attributes
      {
        description: @booking.guest_email,
        token: @stripe_token,
        use_test_api: @booking.organisation_on_trial?
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
      return false if retrieved_customer.present?
    rescue Stripe::InvalidRequestError
      true
    end

    def new_customer
      External::StripeApi::Customer.create(attributes)
    end

    def retrieved_customer
      @retrieved_customer ||=
        External::StripeApi::Customer.retrieve(customer_id: @booking.stripe_customer_id, use_test_api: @booking.organisation_on_trial?)
    end
  end
end
