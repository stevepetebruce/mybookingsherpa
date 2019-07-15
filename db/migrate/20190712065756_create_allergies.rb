class CreateAllergies < ActiveRecord::Migration[5.2]
  def change
    create_table :allergies, id: :uuid do |t|
      t.string :name
      t.uuid :allergic_id
      t.string :allergic_type

      t.timestamps
    end
    add_index :allergies, [:allergic_type, :allergic_id]
  end
end
