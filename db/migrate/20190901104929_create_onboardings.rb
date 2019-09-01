class CreateOnboardings < ActiveRecord::Migration[5.2]
  def change
    create_table :onboardings, id: :uuid do |t|
      t.jsonb :events, default: []
      t.references :organisation, foreign_key: true, index: true, type: :uuid

      t.timestamps
    end
    add_index  :onboardings, :events, using: :gin
  end
end
