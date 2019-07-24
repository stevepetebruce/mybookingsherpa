# Polymorphic model. A booking and a guest can have dietary requirements.
class DietaryRequirement < ApplicationRecord
  POSSIBLE_DIETARY_REQUIREMENTS = %w[vegan vegetarian other].freeze

  belongs_to :dietary_requirable, polymorphic: true, optional: true

  validates :name, presence: true
  validates_inclusion_of :name, in: POSSIBLE_DIETARY_REQUIREMENTS
end
