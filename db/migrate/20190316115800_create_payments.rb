class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments, id: :uuid do |t|
      t.integer :amount
      t.jsonb :raw_response
      t.references :booking, foreign_key: true, index: true, type: :uuid

      t.timestamps
    end
  end
end
