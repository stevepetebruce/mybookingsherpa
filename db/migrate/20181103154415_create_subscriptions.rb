class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.column :created_by_id, :uuid
      t.column :updated_by_id, :uuid

      t.references :organisation, type: :uuid, foreign_key: true, index: true
      t.references :plan, type: :uuid, foreign_key: true, index: true

      t.timestamps
    end
    add_index :subscriptions, :created_by_id
    add_index :subscriptions, :updated_by_id
  end
end
