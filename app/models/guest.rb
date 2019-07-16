class Guest < ApplicationRecord
  include GuestValidations
  include GuestCallbacks

  REQUIRED_ADVANCED_PERSONAL_DETAILS = %i[country date_of_birth next_of_kin_name
                                          next_of_kin_phone_number phone_number].freeze

  REQUIRED_BASIC_PERSONAL_DETAILS = %i[email name].freeze

  UPDATABLE_FIELDS = %i[country
                        date_of_birth dietary_requirements
                        name other_information
                        next_of_kin_name next_of_kin_phone_number
                        phone_number].freeze

  POSSIBLE_DIETARY_REQUIREMENTS = %i[none other vegan vegetarian]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum dietary_requirements: POSSIBLE_DIETARY_REQUIREMENTS, _prefix: true
  enum dietary_requirements_booking: POSSIBLE_DIETARY_REQUIREMENTS, _prefix: true
  enum dietary_requirements_override: POSSIBLE_DIETARY_REQUIREMENTS, _prefix: true

  has_many :allergies, as: :allergic
  has_many :bookings
  has_many :trips, through: :bookings

  def most_recent_booking
    bookings.most_recent.first
  end

  def password_required?
    false
  end
end
