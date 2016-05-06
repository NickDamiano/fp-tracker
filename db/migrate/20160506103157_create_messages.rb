class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
    	t.string :messageSid
    	t.string :from
    	t.string :to
    	t.string :body
    	t.datetime :time_received
    	t.belongs_to :employee, index: true


      t.timestamps null: false
    end
  end
end
