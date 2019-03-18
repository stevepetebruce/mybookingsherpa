module Bookings
  # Updates a booking's status based on:
  # yellow = Not fully paid or lacking full personal details.
  # green = Fully paid + full personal details.
  class StatusUpdater
    def initialize(booking)
      @booking = booking
    end

    def update
      @booking.update(status: new_status)
    end

    def new_status
      return :yellow if no_payments? || only_deposit_paid?
      return :yellow if full_amount_paid? && personal_details_incomplete?

      :green
    end

    private

    def details_incomplete?(attributes)
      attributes
        .slice(*Guest::REQUIRED_ADVANCED_PERSONAL_DETAILS.map(&:to_s))
        .compact
        .empty?
    end

    def full_amount_paid?
      total_paid >= @booking.full_cost
    end

    def no_payments?
      @booking.payments.empty?
    end

    def only_deposit_paid?
      total_paid < @booking.full_cost
    end

    def total_paid
      @booking.payments.pluck(:amount).reduce(:+)
    end

    def personal_details_incomplete?
      details_incomplete?(@booking.attributes) &&
        details_incomplete?(@booking.guest.attributes)
    end
  end
end
