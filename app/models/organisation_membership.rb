class OrganisationMembership < ApplicationRecord
  belongs_to :organisation
  belongs_to :guide

  validates_uniqueness_of :guide, scope: :organisation
end
