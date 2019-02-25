class AddFieldsToBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :country, :string
    add_column :bookings, :phone_number, :string
    add_column :bookings, :date_of_birth, :datetime
    add_column :bookings, :address, :string
    add_column :bookings, :city, :string
    add_column :bookings, :county, :string
    add_column :bookings, :post_code, :string
    add_column :bookings, :next_of_kin_name, :string
    add_column :bookings, :next_of_kin_phone_number, :string
    add_column :bookings, :dietary_requirements, :integer
    add_column :bookings, :allergies, :integer
    add_column :bookings, :medical_conditions, :text
  end
end
