class RenameStripeAccountIdOnOrganisations < ActiveRecord::Migration[5.2]
  def change
    rename_column :organisations, :stripe_account_id, :stripe_account_id_live
  end
end
