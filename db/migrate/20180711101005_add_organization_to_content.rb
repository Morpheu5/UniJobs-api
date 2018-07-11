class AddOrganizationToContent < ActiveRecord::Migration[5.2]
  def change
    add_reference :contents, :organization, foreign_key: true
  end
end
