class AddStripePaymentIntentIdToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :stripe_payment_intent_id, :string
  end
end
