# A join between a guest and a trip. A guest creates a booking on a trip.
class Booking < ApplicationRecord
  enum allergies: %i[dairy eggs nuts penicillin soya]
  enum dietary_requirements: %i[other vegan vegetarian]
  enum status: %i[yellow green]

  belongs_to :trip
  belongs_to :guest, optional: true
  has_many :payments

  delegate :name, :email, to: :guide, prefix: true
  delegate :name, :email, to: :guest, prefix: true

  delegate :currency, :deposit_cost, :full_cost, :guide,
           :organisation_name, :start_date, :end_date, to: :trip
  delegate :description, :maximum_number_of_guests, :name,
           :guest_count, to: :trip, prefix: true

  validates :country, format: GuestValidations::COUNTRY_REGEX, allow_blank: true
  validates :email, format: GuestValidations::EMAIL_REGEX, presence: true
  validates :name, format: GuestValidations::NAME_REGEX, allow_blank: true
  validates :next_of_kin_name, format: GuestValidations::NAME_REGEX, allow_blank: true
  validates :next_of_kin_phone_number, format: GuestValidations::PHONE_NUMBER_REGEX, allow_blank: true
  validates :phone_number, format: GuestValidations::PHONE_NUMBER_REGEX, allow_blank: true

  scope :most_recent, -> { order(created_at: :desc) }

  before_save :update_status

  private

  def update_status
    self[:status] = Bookings::Status.new(self).new_status
  end
end
