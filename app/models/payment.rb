class Payment < ApplicationRecord
  belongs_to :booking

  scope :most_recent, -> { order(created_at: :desc) }

  after_save :update_booking_payment_status

  def failed?
    raw_response&.dig("failure_code").present?
  end

  def failure_message
    raw_response&.dig("failure_message")
  end

  private

  def update_booking_payment_status
    Bookings::UpdatePaymentStatusJob.perform_later(booking)
  end
end
