# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
      t.string :name
      t.references :parent, foreign_key: { to_table: :organizations }

      t.timestamps
    end
    add_index :organizations, :name
  end
end
