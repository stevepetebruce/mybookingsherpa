module Bookings
  class PayOutstandingTripCostJob < ApplicationJob
    queue_as :default

    def perform(booking)
      return unless full_payment_required?(booking)

      Payments::Factory.new(booking, charge(booking)).create
    end

    private

    def charge(booking)
      begin
        response = Bookings::Payment.new(booking).charge
      rescue Stripe::CardError => e
        response = @stripe_api_error = "Payment unsuccessful. #{e&.json_body&.dig(:error, :message)}"
      rescue Stripe::StripeError => e
        response = @stripe_api_error = "Payment unsuccessful. #{type_of_stripe_exception(e)}. Please try again or contact Guide for help."
      end
      response
    end

    def full_payment_required?(booking)
      Bookings::PaymentStatus.new(booking).payment_required?
    end

    def type_of_stripe_exception(exception)
      exception.inspect.split(":").last.gsub(">", "")
    end
  end
end
