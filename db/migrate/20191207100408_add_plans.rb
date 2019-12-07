class AddPlans < ActiveRecord::Migration[5.2]
  def change
    Plan.create(name: "free", charge_type: :percentage, percentage_amount: 0)
    Plan.create(name: "discount (0.5%)", charge_type: :percentage, percentage_amount: 0.005)
    Plan.create(name: "regular", charge_type: :percentage, percentage_amount: 0.01)
  end
end
