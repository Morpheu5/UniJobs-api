class AddGenderToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :gender, :string, null: true, default: nil
  end
end
