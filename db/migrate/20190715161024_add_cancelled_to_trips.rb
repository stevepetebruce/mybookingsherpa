class AddCancelledToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :cancelled, :boolean, default: false
  end
end
