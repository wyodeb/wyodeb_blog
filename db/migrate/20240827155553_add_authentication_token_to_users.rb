class AddAuthenticationTokenToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :authentication_token, :string
    add_index :users, :authentication_token
  end
end
