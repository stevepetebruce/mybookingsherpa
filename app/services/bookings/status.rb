module Bookings
  # Handles bookings' status.
  class Status
    def initialize(booking)
      @booking = booking
    end

    def allergies?
      @booking.allergies.present? ||
        @booking.guest.allergies.present?
    end

    def dietary_requirements?
      @booking.dietary_requirements.present? ||
        @booking.guest.dietary_requirements.present?
    end

    def medical_conditions?
      @booking.medical_conditions.present? ||
        @booking.guest.medical_conditions.present?
    end

    def new_status
      return :yellow if no_payments? || only_deposit_paid?
      return :yellow if full_amount_paid? && personal_details_incomplete?

      :green # fully paid and all personal details complete
    end

    def payment_required?
      total_paid < @booking.full_cost
    end

    def personal_details_incomplete?
      details_incomplete?(@booking.attributes) &&
        details_incomplete?(@booking.guest.attributes)
    end

    def update
      @booking.update(status: new_status)
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
      @total_paid ||= @booking.payments.pluck(:amount).reduce(:+).presence || 0
    end
  end
end
