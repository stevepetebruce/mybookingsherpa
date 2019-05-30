class AddStripeCustomerDataToGuests < ActiveRecord::Migration[5.2]
  def change
    add_column :guests, :stripe_customer_id, :string
  end
end
