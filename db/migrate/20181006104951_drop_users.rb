class DropUsers < ActiveRecord::Migration[5.2]
  def change
    drop_table :trips_users, force: :cascade
    drop_table :users, force: :cascade
  end
end
