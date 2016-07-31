class AddLocationToMessage < ActiveRecord::Migration
  def change
  	add_column :messages, :location, :string 
  end
end
