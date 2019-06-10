class AddDepositPercentageAndFullPaymentWindowToOrganisationsAndTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :deposit_percentage, :integer
    add_column :organisations, :full_payment_window_weeks, :integer
    add_column :trips, :deposit_percentage, :integer
    add_column :trips, :full_payment_window_weeks, :integer
  end
end
