class ChangeTripsCostsToIntegers < ActiveRecord::Migration[5.2]
  def change
    change_column :trips, :full_cost, :integer
    change_column :trips, :deposit_cost, :integer
  end
end
