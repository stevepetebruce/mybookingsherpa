module Guests
  # Updates a guest's fields based on prioritised, updatable fields
  class Updater
    UPDATABLE_FIELDS = %i[address allergies city country county
                          date_of_birth dietary_requirements
                          medical_conditions name
                          next_of_kin_name next_of_kin_phone_number
                          phone_number post_code].freeze

    def initialize(guest)
      @guest = guest
    end

    def update_fields
      return if filtered_updatable_attributes.empty?

      @guest.update_columns(filtered_updatable_attributes)
    end

    private

    # reject any booking_attributes that have a correspondong _override
    def filtered_source_attributes
      all_source_attributes.reject do |k, _v|
        k.end_with?("_booking") && all_source_attributes[k.gsub("_booking", "_override")].present?
      end
    end

    # reject any booking_attributes that have a cannonical field that has a value already
    def booking_fields_with_empty_cannonical
      filtered_source_attributes.reject do |k, _v|
        k.end_with?("_booking") && @guest.read_attribute(k.gsub("_booking", "")).present?
      end.compact
    end

    # strip _booking and _override postfix from attributes hash
    def filtered_updatable_attributes
      booking_fields_with_empty_cannonical.map { |k, v| [k.gsub(%r{_booking|_override}, ""), v] }.to_h
    end

    def booking_attributes
      @guest.attributes.slice(*UPDATABLE_FIELDS.map { |field| "#{field}_booking" })
    end

    def override_attributes
      @guest.attributes.slice(*UPDATABLE_FIELDS.map { |field| "#{field}_override" })
    end

    def all_source_attributes
      booking_attributes.merge(override_attributes)
    end

    def updatable_attributes
      booking_attributes.map { |k, v| [k.gsub("_booking", ""), v] }.to_h
    end
  end
end
