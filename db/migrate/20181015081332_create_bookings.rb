class CreateBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings, id: :uuid do |t|
      t.column :status, :integer, default: 0
      t.column :created_by_id, :uuid
      t.column :updated_by_id, :uuid

      t.references :trip, foreign_key: true, index: true, type: :uuid
      t.references :guest, foreign_key: true, index: true, type: :uuid

      t.timestamps
    end

    add_index :bookings, :created_by_id
    add_index :bookings, :updated_by_id
  end
end
