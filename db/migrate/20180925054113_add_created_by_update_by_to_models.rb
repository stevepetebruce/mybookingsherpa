class AddCreatedByUpdateByToModels < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :created_by_id, :uuid
    add_column :users, :updated_by_id, :uuid
    add_column :trips_users, :created_by_id, :uuid
    add_column :trips_users, :updated_by_id, :uuid

    add_foreign_key :trips_users, :users, column: :created_by_id, primary_key: :id
    add_foreign_key :trips_users, :users, column: :updated_by_id, primary_key: :id
  end
end
