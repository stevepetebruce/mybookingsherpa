class Organisation < ApplicationRecord
  include OrganisationDecorator
  enum currency: %i[eur gbp usd]

  validates :deposit_percentage, numericality: { only_integer: true }, allow_nil: true
  validates :full_payment_window_weeks, numericality: { only_integer: true }, allow_nil: true
  validates :name, format: /\A[\sa-zA-Z0-9_.'\-]+\z/, allow_nil: true
  validates :stripe_account_id, format: /\A[a-zA-Z0-9_\-]{5,50}\z/, allow_blank: true #TODO: move this to stripe_account
  validates :subdomain, format: /\A([a-zA-Z0-9]{1}[a-zA-Z0-9_\-]{2,30})\z/, allow_blank: true

  has_many :organisation_memberships
  has_many :guides, through: :organisation_memberships
  has_one :subscription
  has_many :trips
  has_many :bookings, through: :trips
  has_many :guests, through: :trips
  has_one :onboarding

  has_one_attached :logo_image

  after_create :create_onboarding

  delegate :complete?, to: :onboarding, prefix: true, allow_nil: true
  delegate :solo_founder?, to: :onboarding

  def on_trial?
    !onboarding_complete?
  end

  def owner
    organisation_memberships.owners&.first&.guide
  end

  def plan
    subscription&.plan
  end

  private

  def create_onboarding
    Onboardings::FactoryJob.perform_later(self)
  end
end
