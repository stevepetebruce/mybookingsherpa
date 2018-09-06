class CreateTrips < ActiveRecord::Migration[5.2]
  def change
    create_table :trips, id: :uuid do |t|
      t.string :name
      t.datetime :start_date
      t.datetime :end_date
      t.integer :minimum_number_of_guests
      t.integer :maximum_number_of_guests

      t.uuid :created_by_id
      t.uuid :updated_by_id

      t.timestamps
    end
    add_foreign_key :trips, :users, column: :created_by_id, primary_key: :id
    add_foreign_key :trips, :users, column: :updated_by_id, primary_key: :id
  end
end
