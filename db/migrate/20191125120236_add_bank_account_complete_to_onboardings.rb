class AddBankAccountCompleteToOnboardings < ActiveRecord::Migration[5.2]
  def change
    add_column :onboardings, :bank_account_complete, :boolean, default: false
  end
end
