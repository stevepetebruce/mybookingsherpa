class AddGuestRelatedFieldsToBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :email, :string
    add_column :bookings, :first_name, :string
    add_column :bookings, :last_name, :string
  end
end
