# frozen_string_literal: true

class AssociateUsersAndOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations_users, id: false do |t|
      t.belongs_to :organization, index: true
      t.belongs_to :user, index: true

      t.datetime :created_at, null: false
    end
  end
end
