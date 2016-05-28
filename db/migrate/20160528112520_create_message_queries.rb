class CreateMessageQueries < ActiveRecord::Migration
  def change
    create_table :message_queries do |t|
      t.string :body
      t.string :to

      t.timestamps null: false
    end
  end
end
