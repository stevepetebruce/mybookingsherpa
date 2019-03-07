module Guests
  # Updates a guest's fields based on what other model passed in ex: booking model.
  class BookingUpdater
    UPDATABLE_FIELDS = %w[address allergies city country county date_of_birth
                          dietary_requirements email medical_conditions name
                          next_of_kin_name next_of_kin_phone_number phone_number
                          post_code].freeze

    def initialize(guest)
      @guest = guest
    end

    def copy_booking_values(booking)
      @guest.update(updatable_booking_attributes(booking))
    end

    private

    def updatable_booking_attributes(booking)
      booking.attributes.slice(*UPDATABLE_FIELDS)
             .map { |k, v| ["#{k}_booking", v] }.to_h
    end
  end
end
