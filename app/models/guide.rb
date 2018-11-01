class Guide < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :organisation_memberships
  has_many :organisations, through: :organisation_memberships
  has_and_belongs_to_many :trips

  validates :email, format: /\A\w+@\w+\.{1}[a-zA-Z]{2,}\z/, presence: true, uniqueness: true
  validates :name, format: /\A[\sa-zA-Z0-9_.'\-]+\z/, allow_blank: true
  validates :phone_number, format: /\A[0-9+.x()\-\s]{7,}\z/, allow_blank: true
end
