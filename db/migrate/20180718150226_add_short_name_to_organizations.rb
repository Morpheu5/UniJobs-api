class AddShortNameToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :short_name, :string
  end
end
