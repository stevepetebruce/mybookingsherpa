# Super class for all users: guests, guides.
class User < ApplicationRecord
  validates :email, format: /\A\w+@\w+\.{1}[a-zA-Z]{2,}\z/, presence: true, uniqueness: true
  validates :name, format: /\A[\sa-zA-Z0-9_.\-]+\z/, allow_blank: true
  validates :phone_number, format: /\A[0-9+.x()\-]{7,}\z/, allow_blank: true
  validates :type, inclusion: { in: %w(Guide Guest),
    message: "%{value} is not a valid type of user" }, presence: true
end
