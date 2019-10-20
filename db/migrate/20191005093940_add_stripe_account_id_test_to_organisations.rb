class AddStripeAccountIdTestToOrganisations < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :stripe_account_id_test, :string
  end
end
