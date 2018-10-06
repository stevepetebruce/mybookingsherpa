class DropUsers < ActiveRecord::Migration[5.2]
  def change
    drop_table :trips_users
    drop_table :users
  end
end
