module GuestCallbacks
  extend ActiveSupport::Concern

  UPDATABLE_FIELDS = %i[address allergies city country county
                        date_of_birth dietary_requirements
                        medical_conditions name
                        next_of_kin_name next_of_kin_phone_number
                        phone_number post_code].freeze

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
