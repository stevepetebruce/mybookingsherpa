# A join between a guest and a trip. A guest creates a booking on a trip.
class Booking < ApplicationRecord
  enum allergies: Guest::POSSIBLE_ALLERGIES, _prefix: true
  enum dietary_requirements: Guest::POSSIBLE_DIETARY_REQUIREMENTS, _prefix: true
  enum status: %i[yellow green]

  belongs_to :trip
  belongs_to :guest, optional: true
  has_many :payments
  has_one :organisation, through: :trip

  delegate :name, :email, to: :guide, prefix: true
  delegate :name, :email, to: :guest, prefix: true

  delegate :currency, :deposit_cost, :full_cost, :guide,
           :organisation_name, :organisation_stripe_account_id,
           :start_date, :end_date, to: :trip
  delegate :description, :maximum_number_of_guests, :name,
           :guest_count, to: :trip, prefix: true
  delegate :country, to: :guest, prefix: true

  delegate :logo_image, to: :organisation, prefix: true

  validates :country, format: Regex::COUNTRY, allow_blank: true
  validates :email, format: Regex::EMAIL, presence: true
  validates :name, format: Regex::NAME, allow_blank: true
  validates :next_of_kin_name, format: Regex::NAME, allow_blank: true
  validates :next_of_kin_phone_number, format: Regex::PHONE_NUMBER, allow_blank: true
  validates :phone_number, format: Regex::PHONE_NUMBER, allow_blank: true

  scope :most_recent, -> { order(created_at: :desc) }
  scope :highest_priority, -> { order(priority: :desc) }

  before_save :update_priority
  before_save :update_status
  before_validation :enums_none_to_nil

  private

  def enums_none_to_nil
    self[:allergies] = nil if allergies&.to_sym == :none
    self[:dietary_requirements] = nil if dietary_requirements&.to_sym == :none
  end

  def update_priority
    self[:priority] = Bookings::Priority.new(self).new_priority
  end

  def update_status
    self[:status] = Bookings::Status.new(self).new_status
  end
end
