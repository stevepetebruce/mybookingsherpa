class AddCountryCodeToOrganisations < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :country_code, :string
  end
end
