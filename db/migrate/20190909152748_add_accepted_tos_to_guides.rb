class AddAcceptedTosToGuides < ActiveRecord::Migration[5.2]
  def change
    add_column :guides, :accepted_tos, :boolean, default: true
  end
end
