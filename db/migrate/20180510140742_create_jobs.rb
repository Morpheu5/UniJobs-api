class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.string :title
      t.jsonb :body

      t.timestamps
    end
  end
end
