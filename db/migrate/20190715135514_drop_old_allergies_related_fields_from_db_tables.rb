class DropOldAllergiesRelatedFieldsFromDbTables < ActiveRecord::Migration[5.2]
  def change
    remove_column :bookings, :allergies
    remove_column :guests, :allergies
    remove_column :guests, :allergies_booking
    remove_column :guests, :allergies_override
  end
end
