# Represents a trip in the system.
class Trip < ApplicationRecord
  enum currency: %i[eur gbp usd]

  validates :full_cost, presence: true
  validates :maximum_number_of_guests, presence: true
  validate :start_date_before_end_date
  validates :name, format: /\A[a-zA-Z0-9_.'\-\s]+\z/, presence: true # TODO: make this unique within an organisation's scope
  validates :minimum_number_of_guests,
            numericality: { only_integer: true },
            allow_nil: true
  validates :maximum_number_of_guests,
            numericality: { only_integer: true },
            allow_nil: false

  belongs_to :organisation
  has_many :bookings
  has_many :guests, through: :bookings
  has_and_belongs_to_many :guides
  has_many :organisation_memberships, through: :guides

  delegate :name, :stripe_account_id, to: :organisation, prefix: true

  scope :start_date_asc, -> { order(start_date: :asc) }

  def currency
    self[:currency] || organisation.currency
  end

  def guest_count
    # TODO: need to look into this...
    # A booking, in the future may have more than one guest.
    # But guests.count (has_many :guests, through: :bookings)
    # could be a circular reference.
    bookings.count
  end

  def decorated_bookings
    bookings.most_recent.map { |booking| BookingDecorator.new(booking) }
  end

  def guide
    organisation_memberships.owners&.first&.guide
  end

  def start_date_before_end_date
    return if start_date.nil? && end_date.nil?
    return if start_date <= end_date

    errors.add(:base,
               :start_date_after_end_date,
               message: "start date must be before end date")
  end

  def valid_date_format
    # TODO: implement when we know the format of date string we are receiving
  end
end
