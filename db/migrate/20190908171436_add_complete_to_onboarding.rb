class AddCompleteToOnboarding < ActiveRecord::Migration[5.2]
  def change
    add_column :onboardings, :complete, :boolean, default: false
  end
end
