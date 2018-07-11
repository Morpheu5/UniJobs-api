# frozen_string_literal: true

class CreateContentBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :content_blocks do |t|
      t.references :content, foreign_key: true
      t.uuid :uuid, default: 'uuid_generate_v4()'
      t.string :block_type
      t.integer :order
      t.jsonb :body

      t.timestamps
    end
  end
end
