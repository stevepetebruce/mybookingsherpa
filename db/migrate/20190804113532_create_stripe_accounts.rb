class CreateStripeAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :stripe_accounts, id: :uuid do |t|
      t.string :external_account

      t.string :account_opener_first_name
      t.string :account_opener_last_name
      t.string :account_opener_address_city
      t.string :account_opener_address_line1
      t.string :account_opener_address_postal_code
      t.integer :account_opener_dob_day
      t.integer :account_opener_dob_month
      t.integer :account_opener_dob_year

      t.string :company_name
      t.string :company_address_line1
      t.string :company_address_city
      t.string :company_address_postal_code
      t.string :company_tax_id

      t.string :business_type

      t.datetime :tos_acceptance_date
      t.string :tos_acceptance_ip

      t.string :stripe_account_id

      t.jsonb :directors_data
      t.jsonb :owners_data

      t.jsonb :raw_response

      t.references :organisation, foreign_key: true, index: true, type: :uuid

      t.timestamps
    end
  end
end
