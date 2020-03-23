# Represents a trip in the system.
class Trip < ApplicationRecord
  include TripDecorator
  enum currency: %i[eur gbp usd]

  DEFAULT_CURRENCY = "eur"

  validates :deposit_percentage, numericality: { only_integer: true }, allow_nil: true
  validate :deposit_and_full_payment_window_both_present
  validates :full_cost, presence: true
  validates :full_payment_window_weeks, numericality: { only_integer: true }, allow_nil: true
  validates :maximum_number_of_guests, presence: true
  validate :minimum_number_of_guests_must_not_be_greater_than_maximum
  validate :start_date_before_end_date
  validates :name, presence: true # TODO: make this unique within an organisation's scope
  validates :minimum_number_of_guests,
            numericality: { only_integer: true },
            allow_nil: true
  validates :maximum_number_of_guests,
            numericality: { only_integer: true },
            allow_nil: false

  validates :slug, uniqueness: true

  belongs_to :organisation
  has_many :bookings
  has_many :guests, through: :bookings
  has_and_belongs_to_many :guides
  has_many :organisation_memberships, through: :guides

  delegate :logo_image, :name, :on_trial?, :stripe_account_id, :subdomain_or_www, to: :organisation, prefix: true

  scope :future_trips, -> { end_date_asc.where("end_date > ?", Time.zone.yesterday.end_of_day) }
  scope :past_trips, -> { end_date_desc.where("end_date < ?", Time.zone.now.beginning_of_day) }
  scope :end_date_asc, -> { order(end_date: :asc) }
  scope :end_date_desc, -> { order(end_date: :desc) }

  before_create :set_slug
  before_save :set_deposit_cost

  def currency
    self[:currency] || organisation&.currency || DEFAULT_CURRENCY
  end

  def full_cost=(value)
    super(value.to_i * 100) unless value.nil? # save it in cents
  end

  def full_payment_date
    return if full_payment_window_weeks.nil?

    start_date - full_payment_window_weeks.weeks
  end

  def guest_count
    # TODO: need to look into this...
    # A booking, in the future may have more than one guest.
    # But guests.count (has_many :guests, through: :bookings)
    # could be a circular reference.
    bookings.count
  end

  def guide
    organisation_memberships.owners&.first&.guide
  end

  def has_minimum_number_of_guests?
    guest_count >= minimum_number_of_guests
  end

  def start_date_before_end_date
    return if start_date.nil? && end_date.nil?
    return if end_date >= start_date

    errors.add(:base,
               :start_date_after_end_date,
               message: "Start date must not be after end date")
  end

  def valid_date_format
    # TODO: implement when we know the format of date string we are receiving
  end

  private

  def deposit_and_full_payment_window_both_present
    return if deposit_percentage && full_payment_window_weeks ||
      !full_payment_window_weeks && !deposit_percentage

    errors.add(:base,
               :deposit_and_full_payment_window_both_present,
               message: "If you have a deposit you must also have a full payment window")
  end

  def generated_slug
    @generated_slug ||= name.parameterize(separator: "_").truncate(80, omission: "")
  end

  def minimum_number_of_guests_must_not_be_greater_than_maximum
    return if minimum_number_of_guests.nil? || maximum_number_of_guests.nil?
    return if minimum_number_of_guests <= maximum_number_of_guests

    errors.add(:base,
               :minimum_number_of_guests_must_not_be_greater_than_maximum,
               message: "Minimum number of guests must not be greater than maximum")
  end

  def set_deposit_cost
    return if deposit_percentage.nil?

    self[:deposit_cost] = Trips::DepositCalculator.calculate_deposit(self)
  end

  def set_slug
    if Trip.find_by_slug(generated_slug)
      self[:slug] = "#{SecureRandom.hex(8)}_#{generated_slug}"
    else
      self[:slug] = generated_slug
    end
  end
end
