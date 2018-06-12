class CreateContent < ActiveRecord::Migration[5.2]
  def change
    create_table :contents do |t|
      t.string :content_type
      t.jsonb :title
      t.jsonb :metadata
    end
  end
end
