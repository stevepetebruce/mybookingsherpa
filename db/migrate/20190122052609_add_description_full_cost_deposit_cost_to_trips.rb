class AddDescriptionFullCostDepositCostToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :description, :text
    add_column :trips, :full_cost, :float
    add_column :trips, :deposit_cost, :float
  end
end
