class Guide < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_and_belongs_to_many :trips
  has_many :bookings, through: :trips
  has_many :guests, through: :trips
  has_many :organisation_memberships
  has_many :organisations, through: :organisation_memberships

  validates :email, format: Regex::EMAIL, presence: true, uniqueness: true
  validates :name, format: Regex::NAME, allow_blank: true
  validates :phone_number, format: Regex::PHONE_NUMBER, allow_blank: true

  def on_trial?
    # TODO: will need a way to select current organisation when guides belong
    #   to more than one organisation...
    organisation_memberships.owners.last.organisation.on_trial?
  end
end
