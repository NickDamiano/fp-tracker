class AddPendingResponseToMessages < ActiveRecord::Migration
  def change
  	add_column :messages, :pending_response, :boolean 
  end
end
