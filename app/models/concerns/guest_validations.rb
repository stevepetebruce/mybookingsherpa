module GuestValidations
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  included do
    validates :country, format: Regex::COUNTRY, allow_blank: true
    validates :country_booking, format: Regex::COUNTRY, allow_blank: true
    validates :country_override, format: Regex::COUNTRY, allow_blank: true
    validates :email, format: Regex::EMAIL, presence: true, uniqueness: true
    validates :email_booking, format: Regex::EMAIL, allow_blank: true, uniqueness: true
    validates :email_override, format: Regex::EMAIL, allow_blank: true, uniqueness: true
    validates :name, format: Regex::NAME, allow_blank: true
    validates :name_booking, format: Regex::NAME, allow_blank: true
    validates :name_override, format: Regex::NAME, allow_blank: true
    validates :next_of_kin_name, format: Regex::NAME, allow_blank: true
    validates :next_of_kin_name_booking, format: Regex::NAME, allow_blank: true
    validates :next_of_kin_name_override, format: Regex::NAME, allow_blank: true
    validates :next_of_kin_phone_number, format: Regex::PHONE_NUMBER, allow_blank: true
    validates :next_of_kin_phone_number_booking, format: Regex::PHONE_NUMBER, allow_blank: true
    validates :next_of_kin_phone_number_override, format: Regex::PHONE_NUMBER, allow_blank: true
    validates :phone_number, format: Regex::PHONE_NUMBER, allow_blank: true
    validates :phone_number_booking, format: Regex::PHONE_NUMBER, allow_blank: true
    validates :phone_number_override, format: Regex::PHONE_NUMBER, allow_blank: true
    # TODO:  date_of_birth / date_of_birth_booking / date_of_birth_override
  end
end
