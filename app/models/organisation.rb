class Organisation < ApplicationRecord
  enum currency: %i[eur gbp usd]

  validates :currency, presence: true
  validates :deposit_percentage, numericality: { only_integer: true }, allow_nil: true
  validates :full_payment_window_weeks, numericality: { only_integer: true }, allow_nil: true
  validates :name, format: /\A[\sa-zA-Z0-9_.'\-]+\z/, allow_blank: false, uniqueness: true
  validates :stripe_account_id, format: /\A[a-zA-Z0-9_\-]{5,50}\z/, allow_blank: true
  validates :subdomain, format: /\A([a-zA-Z0-9]{1}[a-zA-Z0-9_\-]{2,30})\z/, allow_blank: true

  has_many :organisation_memberships
  has_many :guides, through: :organisation_memberships
  has_many :subscriptions
  has_many :trips

  has_one_attached :logo_image

  def on_trial?
    current_subscription.nil?
  end

  def owner
    organisation_memberships.owners&.first&.guide
  end

  def plan
    current_subscription&.plan
  end

  private

  def current_subscription
    subscriptions.created_at_desc&.first
  end
end
