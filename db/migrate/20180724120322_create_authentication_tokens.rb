class CreateAuthenticationTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :authentication_tokens do |t|
      t.references :user, foreign_key: true
      t.string :token, index: { unique: true }

      t.timestamps
    end
  end
end
