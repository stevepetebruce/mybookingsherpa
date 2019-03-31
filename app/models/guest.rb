class Guest < ApplicationRecord
  include GuestValidations
  include GuestCallbacks

  REQUIRED_ADVANCED_PERSONAL_DETAILS = %i[address city country county
                                          date_of_birth next_of_kin_name
                                          next_of_kin_phone_number phone_number
                                          post_code].freeze

  REQUIRED_BASIC_PERSONAL_DETAILS = %i[email name].freeze

  UPDATABLE_FIELDS = %i[address allergies city country county
                        date_of_birth dietary_requirements
                        name other_information
                        next_of_kin_name next_of_kin_phone_number
                        phone_number post_code].freeze

  POSSIBLE_ALLERGIES = %i[none other dairy eggs nuts penicillin soya]
  POSSIBLE_DIETARY_REQUIREMENTS = %i[none other vegan vegetarian]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum allergies: POSSIBLE_ALLERGIES, _prefix: true
  enum allergies_booking: POSSIBLE_ALLERGIES, _prefix: true
  enum allergies_override: POSSIBLE_ALLERGIES, _prefix: true
  enum dietary_requirements: POSSIBLE_DIETARY_REQUIREMENTS, _prefix: true
  enum dietary_requirements_booking: POSSIBLE_DIETARY_REQUIREMENTS, _prefix: true
  enum dietary_requirements_override: POSSIBLE_DIETARY_REQUIREMENTS, _prefix: true

  has_many :bookings
  has_many :trips, through: :bookings

  def most_recent_booking
    bookings.most_recent.first
  end

  def password_required?
    false
  end
end
