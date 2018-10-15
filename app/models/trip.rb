class Trip < ApplicationRecord
  validate :start_date_before_end_date
  validates :name, format: /\A[\sa-zA-Z0-9_.\-]+\z/, presence: true # TODO: make this unique within an organisation's scope
  validates :minimum_number_of_guests, numericality: { only_integer: true }, allow_nil: true
  validates :maximum_number_of_guests, numericality: { only_integer: true }, allow_nil: true

  has_and_belongs_to_many :guests
  has_and_belongs_to_many :guides

  has_many :bookings
 
  def valid_date_format
    # TODO: implement when we know the format of the date string we are receiving
  end

  def start_date_before_end_date
    return if start_date.nil? && end_date.nil?
    return if start_date <= end_date

    errors.add(:base, :start_date_after_end_date, message: 'start date must be before end date')
  end
end
