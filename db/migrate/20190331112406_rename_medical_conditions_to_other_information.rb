class RenameMedicalConditionsToOtherInformation < ActiveRecord::Migration[5.2]
  def change
    rename_column :bookings, :medical_conditions, :other_information
    rename_column :guests, :medical_conditions, :other_information
    rename_column :guests, :medical_conditions_booking, :other_information_booking
    rename_column :guests, :medical_conditions_override, :other_information_override
  end
end
