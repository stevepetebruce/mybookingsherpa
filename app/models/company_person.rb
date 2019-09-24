# Represents an director/owner of an organisation/Stripe account.
class CompanyPerson < ApplicationRecord
  enum relationship: %i[director owner]

  belongs_to :organisation
end
