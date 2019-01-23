# A join between a guest and a trip. A guest creates a booking on a trip.
class Booking < ApplicationRecord
  enum status: %i[pending complete]

  belongs_to :trip
  belongs_to :guest, optional: true

  delegate :currency, :deposit_cost, :full_cost,
           :organisation_name, :start_date, :end_date, to: :trip
  delegate :description, :maximum_number_of_guests, :name,
           :guest_count, to: :trip, prefix: true

  validates :email,
            format: %r(\A[a-zA-Z0-9.!#$%&’*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\z),
            presence: true
end
