class CreateJoinTableUsersTrips < ActiveRecord::Migration[5.2]
  def change
    create_join_table :users, :trips, column_options: { type: :uuid } do |t|
      t.index [:user_id, :trip_id], :unique => true
      t.index :trip_id
    end
  end
end
