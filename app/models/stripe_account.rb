# Represents a single Stripe Account associated with an organisation.
class StripeAccount < ApplicationRecord
  belongs_to :organisation
  validates :stripe_account_id, format: /\A[a-zA-Z0-9_\-]{5,50}\z/, allow_blank: true
  # refs:
  # Directors and beneficial owners: https://support.stripe.com/questions/beneficial-owner-and-director-definitions
  # Required fields: https://stripe.com/docs/connect/required-verification-information
end
