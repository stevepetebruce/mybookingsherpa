class AddStatusToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :status, :integer, default: 0
  end
end
