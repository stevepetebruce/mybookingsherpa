module Bookings
  # Given a booking, determines the new value for its priority based on its state.
  class Priority
    PAYMENT_REQUIRED = 3
    BOOKING_DETAILS_REQUIRED = 2
    OTHER_INFORMATION_PRESENT = 1
    NO_ACTION_REQUIRED = 0

    def initialize(booking)
      @booking = booking
    end

    def new_priority
      return PAYMENT_REQUIRED if booking_payment_status.payment_required?
      return BOOKING_DETAILS_REQUIRED if booking_status.personal_details_incomplete?
      return OTHER_INFORMATION_PRESENT if other_information?

      NO_ACTION_REQUIRED
    end

    private

    def booking_payment_status
      @booking_payment_status ||= Bookings::PaymentStatus.new(@booking)
    end

    def booking_status
      @booking_status ||= Bookings::Status.new(@booking)
    end

    def other_information?
      booking_status.allergies? ||
        booking_status.dietary_requirements? ||
        booking_status.other_information?
    end
  end
end
