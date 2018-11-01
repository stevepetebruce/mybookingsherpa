class Organisation < ApplicationRecord
  validates :name, format: /\A[\sa-zA-Z0-9_.'\-]+\z/, allow_blank: false
  validates :stripe_account_id, format: /\A[a-zA-Z0-9_\-]{5,50}\z/, allow_blank: true
  validates :subdomain, format: /\A([a-zA-Z0-9][a-zA-Z0-9_\-]{3,30})\z/, allow_blank: true

  has_many :organisation_memberships
  has_many :guides, through: :organisation_memberships
end
