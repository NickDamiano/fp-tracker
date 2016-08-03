class AddQueryPendingToMessages < ActiveRecord::Migration
  def change
  	add_column :employees, :queries_pending, :boolean 
  end
end
