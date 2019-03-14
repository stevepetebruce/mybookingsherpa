module GuestValidations
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  COUNTRY_REGEX = %r{\A[A-Z]{2,3}\z}.freeze
  EMAIL_REGEX = %r{\A\w+@\w+\.{1}[a-zA-Z]{2,}\z}.freeze
  NAME_REGEX = %r{\A[\sa-zA-Z0-9_.'\-]+\z}.freeze
  PHONE_NUMBER_REGEX = %r{\A[0-9+.x()\-\s]{7,}\z}.freeze

  included do
    validates :country, format: COUNTRY_REGEX, allow_blank: true
    validates :country_booking, format: COUNTRY_REGEX, allow_blank: true
    validates :country_override, format: COUNTRY_REGEX, allow_blank: true
    validates :email, format: EMAIL_REGEX, presence: true, uniqueness: true
    validates :email_booking, format: EMAIL_REGEX, allow_blank: true, uniqueness: true
    validates :email_override, format: EMAIL_REGEX, allow_blank: true, uniqueness: true
    validates :name, format: NAME_REGEX, allow_blank: true
    validates :name_booking, format: NAME_REGEX, allow_blank: true
    validates :name_override, format: NAME_REGEX, allow_blank: true
    validates :next_of_kin_name, format: NAME_REGEX, allow_blank: true
    validates :next_of_kin_name_booking, format: NAME_REGEX, allow_blank: true
    validates :next_of_kin_name_override, format: NAME_REGEX, allow_blank: true
    validates :next_of_kin_phone_number, format: PHONE_NUMBER_REGEX, allow_blank: true
    validates :next_of_kin_phone_number_booking, format: PHONE_NUMBER_REGEX, allow_blank: true
    validates :next_of_kin_phone_number_override, format: PHONE_NUMBER_REGEX, allow_blank: true
    validates :phone_number, format: PHONE_NUMBER_REGEX, allow_blank: true
    validates :phone_number_booking, format: PHONE_NUMBER_REGEX, allow_blank: true
    validates :phone_number_override, format: PHONE_NUMBER_REGEX, allow_blank: true
    # TODO:  date_of_birth / date_of_birth_booking / date_of_birth_override
  end
end
