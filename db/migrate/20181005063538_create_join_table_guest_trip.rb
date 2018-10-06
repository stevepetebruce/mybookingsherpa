class CreateJoinTableGuestTrip < ActiveRecord::Migration[5.2]
  def change
    create_join_table :guests, :trips, column_options: { type: :uuid } do |t|
      t.uuid :created_by_id
      t.uuid :updated_by_id

      t.timestamps null: false

      t.index [:guest_id, :trip_id]
      t.index [:trip_id, :guest_id]
    end
  end
end
