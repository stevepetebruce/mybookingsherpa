class AddStripeAccountCompleteToOnboarding < ActiveRecord::Migration[5.2]
  def change
    add_column :onboardings, :stripe_account_complete, :boolean, default: false
  end
end
