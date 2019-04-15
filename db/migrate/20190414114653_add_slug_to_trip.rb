class AddSlugToTrip < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :slug, :string
    add_index :trips, :slug, unique: true
  end
end
