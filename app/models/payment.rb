class Payment < ApplicationRecord
  enum status: %i[pending success failed refunded]
  belongs_to :booking, optional: true

  scope :most_recent, -> { order(created_at: :desc) }

  after_save :update_booking_payment_status

  validates :stripe_payment_intent_id, uniqueness: true

  # This is breaking the status enum method failed?
  # TODO: need to check where this is used and where raw_response is updated...
  # def failed?
  #   raw_response&.dig("failure_code").present?
  # end

  def failure_message
    raw_response&.dig("failure_message")
  end

  private

  def update_booking_payment_status
    Bookings::UpdatePaymentStatusJob.perform_later(booking) if booking
  end
end
