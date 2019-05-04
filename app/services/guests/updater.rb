module Guests
  # Updates a guest's fields based on what other model passed in ex: booking model.
  class Updater
    UPDATABLE_FIELDS = %w[allergies country date_of_birth dietary_requirements
                          name other_information next_of_kin_name
                          next_of_kin_phone_number phone_number].freeze

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
