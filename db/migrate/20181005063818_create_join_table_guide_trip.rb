class CreateJoinTableGuideTrip < ActiveRecord::Migration[5.2]
  def change
    create_join_table :guides, :trips, column_options: { type: :uuid } do |t|
      t.uuid :created_by_id
      t.uuid :updated_by_id

      t.timestamps null: false

      t.index [:guide_id, :trip_id]
      t.index [:trip_id, :guide_id]
    end
  end
end
