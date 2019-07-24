module GuestCallbacks
  extend ActiveSupport::Concern

  UPDATABLE_FIELDS = %i[country date_of_birth name other_information
                        next_of_kin_name next_of_kin_phone_number phone_number].freeze

  included do
    before_create :set_one_time_login_token
    before_save :set_updatable_fields
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
