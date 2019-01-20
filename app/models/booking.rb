# A join between a guest and a trip. A guest creates a booking on a trip.
class Booking < ApplicationRecord
  enum status: %i[pending complete]

  belongs_to :trip
  belongs_to :guest, optional: true

  delegate :organisation_name, to: :trip

  validates :email,
            format: %r(\A[a-zA-Z0-9.!#$%&’*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\z),
            presence: true
end
