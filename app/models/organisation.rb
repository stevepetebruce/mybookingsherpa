class Organisation < ApplicationRecord
  include OrganisationDecorator
  enum currency: %i[eur gbp usd]

  validates :deposit_percentage, numericality: { only_integer: true }, allow_nil: true
  validates :full_payment_window_weeks, numericality: { only_integer: true }, allow_nil: true
  validates :name, format: /\A[\sa-zA-Z0-9_.'\-]+\z/, allow_nil: true
  validates :stripe_account_id_live, format: /\A[a-zA-Z0-9_\-]{5,50}\z/, allow_blank: true #TODO: move this to stripe_account
  validates :stripe_account_id_test, format: /\A[a-zA-Z0-9_\-]{5,50}\z/, allow_blank: true #TODO: move this to stripe_account
  validates :subdomain, format: /\A([a-zA-Z0-9]{1}[a-zA-Z0-9_\-]{2,30})\z/, allow_blank: true

  has_many :company_people
  has_many :organisation_memberships
  has_many :guides, through: :organisation_memberships
  has_one :subscription
  has_many :trips
  has_many :bookings, through: :trips
  has_many :guests, through: :trips
  has_one :onboarding

  has_one_attached :logo_image

  delegate :complete?, to: :onboarding, prefix: true, allow_nil: true
  delegate :solo_founder?, to: :onboarding
  delegate :stripe_account_complete?, to: :onboarding

  def on_trial?
    !onboarding_complete?
  end

  def owner
    organisation_memberships.owners&.first&.guide
  end

  def plan
    subscription&.plan
  end

  def stripe_account_id
    return stripe_account_id_test if on_trial?

    stripe_account_id_live
  end
end
