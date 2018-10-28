class CreateOrganisations < ActiveRecord::Migration[5.2]
  def change
    create_table :organisations, id: :uuid do |t|
      t.string :name
      t.text :address
      t.string :stripe_account_id
      t.string :subdomain

      t.uuid :created_by_id
      t.uuid :updated_by_id

      t.timestamps
    end
    add_foreign_key :organisations, :guides, column: :created_by_id, primary_key: :id
    add_foreign_key :organisations, :guides, column: :updated_by_id, primary_key: :id
  end
end
