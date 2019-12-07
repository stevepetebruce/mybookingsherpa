# A join between a guest and a trip. A guest creates a booking on a trip.
class Booking < ApplicationRecord
  include BookingDecorator
  enum payment_status: %i[payment_required full_amount_paid payment_failed refunded]

  belongs_to :trip
  belongs_to :guest, optional: true
  has_many :allergies, as: :allergic, dependent: :destroy
  has_many :dietary_requirements, as: :dietary_requirable, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_one :organisation, through: :trip

  delegate :name, :email, to: :guide, prefix: true
  delegate :name, :email, to: :guest, prefix: true

  delegate :currency, :deposit_cost, :end_date, :full_cost,
           :full_payment_date, :guide, :organisation_name,
           :organisation_stripe_account_id,
           :start_date, to: :trip
  delegate :cancelled?, :description, :full_payment_window_weeks,
           :guest_count, :maximum_number_of_guests, :name, :slug,
           to: :trip, prefix: true
  delegate :stripe_customer_id, to: :guest, allow_nil: true

  delegate :logo_image, :on_trial?, :subdomain_or_www, to: :organisation, prefix: true

  validates :country, format: Regex::COUNTRY, allow_blank: true
  validates :email, format: Regex::EMAIL, presence: true
  validates :name, format: Regex::NAME, allow_blank: true
  validates :next_of_kin_name, format: Regex::NAME, allow_blank: true
  validates :next_of_kin_phone_number, format: Regex::PHONE_NUMBER, allow_blank: true
  validates :phone_number, format: Regex::PHONE_NUMBER, allow_blank: true

  scope :highest_priority, -> { order(priority: :desc) }
  scope :most_recent, -> { order(created_at: :desc) }

  before_save :update_priority

  def last_failed_payment
    payments.most_recent.failed.first
  end

  def last_payment
    payments.most_recent.first
  end

  def last_payment_failed?
    last_payment&.failed?
  end

  private

  def update_priority
    self[:priority] = Bookings::Priority.new(self).new_priority
  end
end
