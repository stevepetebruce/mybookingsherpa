class AddBackgroundColorToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :background_color, :string
  end
end
