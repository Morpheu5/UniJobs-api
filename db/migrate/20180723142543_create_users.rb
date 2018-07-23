class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :given_name
      t.string :family_name
      t.string  :role, null: false, default: 'USER'
      t.string :password_digest

      t.timestamps
    end
  end
end
