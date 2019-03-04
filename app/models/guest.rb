class Guest < ApplicationRecord
  include GuestValidations
  include GuestCallbacks

  UPDATABLE_FIELDS = %i[address allergies city country county
                        date_of_birth dietary_requirements
                        medical_conditions name
                        next_of_kin_name next_of_kin_phone_number
                        phone_number post_code].freeze

  POSSIBLE_ALLERGIES = %i[dairy eggs nuts penicillin soya]
  POSSIBLE_DIETARY_REQUIREMENTS = %i[other vegan vegetarian]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum allergies: POSSIBLE_ALLERGIES
  enum dietary_requirements: POSSIBLE_DIETARY_REQUIREMENTS

  has_many :bookings
  has_many :trips, through: :bookings

  def password_required?
    false
  end
end
