module Guests
  # Update guest's booking fields based on most recent associated booking
  class BookingUpdater
    UPDATABLE_FIELDS = %w[address allergies city country county date_of_birth
                          dietary_requirements medical_conditions name
                          next_of_kin_name next_of_kin_phone_number phone_number
                          post_code].freeze

    def initialize(guest)
      @guest = guest
    end

    def copy_booking_values
      @guest.update(updatable_booking_attributes)
    end

    private

    def updatable_booking_attributes
      @guest.most_recent_booking.attributes.
        slice(*UPDATABLE_FIELDS).
        map { |k, v| ["#{k}_booking", v] }.to_h
    end
  end
end
