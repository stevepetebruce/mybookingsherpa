class AddPriorityToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :priority, :integer, default: 0
  end
end
