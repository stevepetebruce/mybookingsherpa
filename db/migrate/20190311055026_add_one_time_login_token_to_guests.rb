class AddOneTimeLoginTokenToGuests < ActiveRecord::Migration[5.2]
  def change
    add_column :guests, :one_time_login_token, :string
    add_index :guests, :one_time_login_token, unique: true
  end
end
