class Subscription < ApplicationRecord
  belongs_to :organisation
  belongs_to :plan

  scope :created_at_desc, -> { order(created_at: :desc) }
end
