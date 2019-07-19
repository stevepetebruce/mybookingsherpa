class AddRefundedToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :refunded, :boolean, default: false
  end
end
