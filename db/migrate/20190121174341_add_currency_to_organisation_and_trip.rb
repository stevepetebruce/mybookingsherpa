class AddCurrencyToOrganisationAndTrip < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :currency, :integer
    add_column :trips, :currency, :integer
  end
end
