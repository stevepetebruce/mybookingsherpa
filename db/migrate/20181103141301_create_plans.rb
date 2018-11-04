class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans, id: :uuid do |t|
      t.string :name
      t.float :flat_fee_amount
      t.float :percentage_amount
      t.integer :charge_type, default: 0

      t.timestamps
    end
  end
end
