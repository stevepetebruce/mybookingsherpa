class Guest < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :bookings
  has_many :trips, through: :bookings

  validates :email, format: /\A\w+@\w+\.{1}[a-zA-Z]{2,}\z/, presence: true, uniqueness: true
  validates :name, format: /\A[\sa-zA-Z0-9_.'\-]+\z/, allow_blank: true
  validates :phone_number, format: /\A[0-9+.x()\-\s]{7,}\z/, allow_blank: true
end
