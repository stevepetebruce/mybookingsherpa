class AddStripeFieldsToBookings < ActiveRecord::Migration[5.2]
  def change
    change_table :bookings do |t|
      t.string :stripe_customer_id
      t.string :stripe_payment_method_id
    end
  end
end
