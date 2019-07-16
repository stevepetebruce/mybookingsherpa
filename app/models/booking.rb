# A join between a guest and a trip. A guest creates a booking on a trip.
class Booking < ApplicationRecord
  include BookingDecorator
  enum dietary_requirements: Guest::POSSIBLE_DIETARY_REQUIREMENTS, _prefix: true
  enum payment_status: %i[yellow green red]

  belongs_to :trip
  belongs_to :guest, optional: true
  has_many :allergies, as: :allergic
  has_many :payments
  has_one :organisation, through: :trip

  delegate :name, :email, to: :guide, prefix: true
  delegate :name, :email, to: :guest, prefix: true

  delegate :currency, :deposit_cost, :full_cost, :full_payment_date,
           :guide, :organisation_name, :organisation_stripe_account_id,
           :start_date, :end_date, to: :trip
  delegate :description, :full_payment_window_weeks, :guest_count,
           :maximum_number_of_guests, :name, :start_date,
           to: :trip, prefix: true
  delegate :stripe_customer_id, to: :guest

  delegate :logo_image, :on_trial?, :subdomain, to: :organisation, prefix: true

  validates :country, format: Regex::COUNTRY, allow_blank: true
  validates :email, format: Regex::EMAIL, presence: true
  validates :name, format: Regex::NAME, allow_blank: true
  validates :next_of_kin_name, format: Regex::NAME, allow_blank: true
  validates :next_of_kin_phone_number, format: Regex::PHONE_NUMBER, allow_blank: true
  validates :phone_number, format: Regex::PHONE_NUMBER, allow_blank: true

  scope :most_recent, -> { order(created_at: :desc) }
  scope :highest_priority, -> { order(priority: :desc) }

  before_save :update_priority
  before_validation :enums_none_to_nil

  def last_payment_failed?
    last_payment&.failed?
  end

  private

  def enums_none_to_nil
    self[:dietary_requirements] = nil if dietary_requirements&.to_sym == :none
  end

  def last_payment
    payments.most_recent.first
  end

  def update_priority
    self[:priority] = Bookings::Priority.new(self).new_priority
  end
end
