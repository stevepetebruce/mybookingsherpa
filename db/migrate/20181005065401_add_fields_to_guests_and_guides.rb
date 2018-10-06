class AddFieldsToGuestsAndGuides < ActiveRecord::Migration[5.2]
  def change
    add_column :guests, :name, :string
    add_column :guests, :phone_number, :string
    add_column :guests, :address, :text

    add_column :guides, :name, :string
    add_column :guides, :phone_number, :string
    add_column :guides, :address, :text
  end
end
