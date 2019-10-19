class CreateSocialPosts < ActiveRecord::Migration[6.0]
  def change
    create_table :social_posts do |t|
      t.references :content, null: false, foreign_key: true
      t.jsonb :status
      t.text :messages

      t.timestamps
    end
  end
end
