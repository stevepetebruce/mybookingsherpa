class Booking < ApplicationRecord
  enum status: [ :pending, :complete ]

  belongs_to :trip
  belongs_to :guest, optional: true
end
