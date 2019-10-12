class AddLogoToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :logo_data, :jsonb
  end
end
