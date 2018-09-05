class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: :uuid do |t|
      t.string :type
      t.string :name
      t.string :email, index: true
      t.string :phone_number
      t.text :address

      t.timestamps
    end
  end
end
