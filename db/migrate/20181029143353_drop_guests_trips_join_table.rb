class DropGuestsTripsJoinTable < ActiveRecord::Migration[5.2]
  def change
    drop_join_table :guests, :trips
  end
end
