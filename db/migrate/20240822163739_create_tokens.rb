class CreateTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :otp
      t.datetime :expires_at

      t.timestamps
    end
  end
end
