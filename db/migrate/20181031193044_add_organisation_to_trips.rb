class AddOrganisationToTrips < ActiveRecord::Migration[5.2]
  def change
    add_reference :trips, :organisation, foreign_key: true, index: true, type: :uuid
  end
end
