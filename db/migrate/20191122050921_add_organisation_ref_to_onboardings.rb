class AddOrganisationRefToOnboardings < ActiveRecord::Migration[5.2]
  def change
    add_reference :onboardings, :organisation, foreign_key: true, index: true, type: :uuid
  end
end
