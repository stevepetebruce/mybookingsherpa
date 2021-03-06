module Bookings
  # Handles bookings' (non-payment) related status.
  class Status
    def initialize(booking)
      @booking = booking
    end

    def allergies?
      @booking.allergies.exists? || @booking.guest.allergies.exists?
    end

    def dietary_requirements?
      @booking.dietary_requirements.exists? || @booking.guest.dietary_requirements.exists?
    end

    def other_information?
      @booking.other_information? || @booking.guest.other_information?
    end

    def personal_details_incomplete?
      details_incomplete?(@booking.attributes) &&
        details_incomplete?(@booking.guest.attributes)
    end

    private

    def details_incomplete?(attributes)
      attributes
        .slice(*Guest::REQUIRED_ADVANCED_PERSONAL_DETAILS.map(&:to_s))
        .compact
        .empty?
    end
  end
end
