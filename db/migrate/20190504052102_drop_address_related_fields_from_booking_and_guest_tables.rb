class DropAddressRelatedFieldsFromBookingAndGuestTables < ActiveRecord::Migration[5.2]
  def change
    remove_column :bookings, :address
    remove_column :bookings, :city
    remove_column :bookings, :county
    remove_column :bookings, :post_code

    remove_column :guests, :address_booking
    remove_column :guests, :address_override
    remove_column :guests, :city_booking
    remove_column :guests, :city_override
    remove_column :guests, :county_booking
    remove_column :guests, :county_override
    remove_column :guests, :post_code_booking
    remove_column :guests, :post_code_override
  end
end
