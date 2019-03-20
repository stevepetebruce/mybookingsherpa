# A join between a guest and a trip. A guest creates a booking on a trip.
class Booking < ApplicationRecord
  enum allergies: %i[dairy eggs nuts penicillin soya]
  enum dietary_requirements: %i[other vegan vegetarian]
  enum status: %i[yellow green]

  belongs_to :trip
  belongs_to :guest, optional: true
  has_many :payments

  delegate :name, :email, to: :guide, prefix: true

  delegate :currency, :deposit_cost, :full_cost, :guide,
           :organisation_name, :start_date, :end_date, to: :trip
  delegate :description, :maximum_number_of_guests, :name,
           :guest_count, to: :trip, prefix: true

  validates :email,
            format: %r(\A[a-zA-Z0-9.!#$%&’*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\z),
            presence: true

  scope :most_recent, -> { order(created_at: :desc) }

  before_save :update_status

  private

  def update_status
    self[:status] = Bookings::Status.new(self).new_status
  end
end
