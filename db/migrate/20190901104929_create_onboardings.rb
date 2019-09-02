class CreateOnboardings < ActiveRecord::Migration[5.2]
  def change
    create_table :onboardings, id: :uuid do |t|
      t.jsonb :events, default: []
      t.timestamps
    end
    add_index  :onboardings, :events, using: :gin
  end
end
