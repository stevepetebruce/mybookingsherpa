class CreateDietaryRequirements < ActiveRecord::Migration[5.2]
  def change
    create_table :dietary_requirements, id: :uuid do |t|
      t.string :name
      t.uuid :dietary_requirable_id
      t.string :dietary_requirable_type

      t.timestamps
    end
    add_index :dietary_requirements, [:dietary_requirable_type, :dietary_requirable_id], name: :index_dietary_requirements
  end
end
