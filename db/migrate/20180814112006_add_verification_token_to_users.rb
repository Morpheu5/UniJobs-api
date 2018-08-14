class AddVerificationTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :verification_token, :string, null: true, default: nil
    add_column :users, :email_verified, :boolean, default: false
  end
end
