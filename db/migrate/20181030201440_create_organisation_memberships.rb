class CreateOrganisationMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :organisation_memberships, id: :uuid do |t|
      t.boolean :owner, default: false
      t.references :organisation, foreign_key: true, index: true, type: :uuid
      t.references :guide, foreign_key: true, index: true, type: :uuid

      t.timestamps
    end
  end
end
