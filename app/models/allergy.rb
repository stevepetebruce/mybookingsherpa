# Polymorphic model. A booking and a guest can have allergies.
class Allergy < ApplicationRecord
  POSSIBLE_FOOD_ALLERGIES = %w[dairy eggs fish gluten nuts shellfish soya other].freeze
  POSSIBLE_MEDICAL_ALLERGIES = %w[aspirin ibuprofen insulin other].freeze
  POSSIBLE_ALLERGIES = POSSIBLE_FOOD_ALLERGIES + POSSIBLE_MEDICAL_ALLERGIES

  belongs_to :allergic, polymorphic: true

  validates :name, presence: true
  validates_inclusion_of :name, in: POSSIBLE_ALLERGIES
end
