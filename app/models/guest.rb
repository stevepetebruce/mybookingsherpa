class Guest < ApplicationRecord
  include GuestValidations
  include GuestCallbacks

  REQUIRED_ADVANCED_PERSONAL_DETAILS = %i[country date_of_birth next_of_kin_name
                                          next_of_kin_phone_number phone_number].freeze

  REQUIRED_BASIC_PERSONAL_DETAILS = %i[email name].freeze

  UPDATABLE_FIELDS = %i[country
                        date_of_birth
                        name other_information
                        next_of_kin_name next_of_kin_phone_number
                        phone_number].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :allergies, as: :allergic
  has_many :bookings
  has_many :dietary_requirements, as: :dietary_requirable
  has_many :trips, through: :bookings

  def most_recent_booking
    bookings.most_recent.first
  end

  def password_required?
    false
  end
end
