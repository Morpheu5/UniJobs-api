# frozen_string_literal: true

class CreateContent < ActiveRecord::Migration[5.2]
  def change
    create_table :contents do |t|
      t.uuid :uuid, default: 'uuid_generate_v4()'
      t.string :content_type
      t.jsonb :title
      t.jsonb :metadata
    end
  end
end
