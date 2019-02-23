class AlterBookingFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :bookings, :first_name
    remove_column :bookings, :last_name
    add_column :bookings, :name, :string
  end
end
