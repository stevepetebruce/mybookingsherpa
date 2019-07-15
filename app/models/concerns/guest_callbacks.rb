module GuestCallbacks
  extend ActiveSupport::Concern

  UPDATABLE_FIELDS = %i[country date_of_birth dietary_requirements
                        name other_information next_of_kin_name
                        next_of_kin_phone_number phone_number].freeze

  included do
    before_create :set_one_time_login_token
    before_save :set_updatable_fields
    before_validation :enums_none_to_nil
  end

  def enums_none_to_nil
    self[:dietary_requirements] = nil if dietary_requirements&.to_sym == :none
  end

  def set_one_time_login_token
    self[:one_time_login_token] = SecureRandom.hex(16)
  end

  def set_updatable_fields
    UPDATABLE_FIELDS.each do |field|
      self[field] = send("#{field}_override").presence || send("#{field}_booking").presence
    end
  end
end
