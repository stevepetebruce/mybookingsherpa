class Organisation < ApplicationRecord
  enum currency: %i[eur gbp usd]

  validates :currency, presence: true
  validates :name, format: /\A[\sa-zA-Z0-9_.'\-]+\z/, allow_blank: false
  validates :stripe_account_id, format: /\A[a-zA-Z0-9_\-]{5,50}\z/, allow_blank: true
  validates :subdomain, format: /\A([a-zA-Z0-9][a-zA-Z0-9_\-]{3,30})\z/, allow_blank: true

  has_many :organisation_memberships
  has_many :guides, through: :organisation_memberships
  has_many :subscriptions
  has_many :trips

  def plan
    current_subscription&.plan
  end

  private

  def current_subscription
    subscriptions.created_at_desc&.first
  end
end
