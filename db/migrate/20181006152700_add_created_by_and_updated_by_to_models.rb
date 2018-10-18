class AddCreatedByAndUpdatedByToModels < ActiveRecord::Migration[5.2]
  def change
    add_column :guests, :created_by_id, :uuid
    add_column :guests, :updated_by_id, :uuid
    add_column :guides, :created_by_id, :uuid
    add_column :guides, :updated_by_id, :uuid
  end
end
