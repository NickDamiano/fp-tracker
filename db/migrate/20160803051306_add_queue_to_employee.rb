class AddQueueToEmployee < ActiveRecord::Migration
  def change
  	add_column :employees, :queued_responses, :boolean 
  end
end
