class CreateCompanyPeople < ActiveRecord::Migration[5.2]
  def change
    create_table :company_people, id: :uuid do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.integer :relationship
      t.string :stripe_person_id

      t.references :organisation, type: :uuid, foreign_key: true, index: true

      t.timestamps
    end
  end
end
