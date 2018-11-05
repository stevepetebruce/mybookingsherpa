class Plan < ApplicationRecord
  enum charge_type: [ :flat_fee, :percentage ]

  has_many :subscriptions

  validates :name, presence: true
  validate :charge_amount_present

  private

  def charge_amount_present
    errors.add(:flat_fee_amount, "can't be blank") if flat_fee? && flat_fee_amount.blank?
    errors.add(:percentage_amount, "can't be blank") if percentage? && percentage_amount.blank?
  end
end
