class CreateContentBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :content_blocks do |t|
      t.references :content, foreign_key: true
      t.string :block_type
      t.integer :order
      t.jsonb :body
    end
  end
end
