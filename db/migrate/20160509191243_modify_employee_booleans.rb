class ModifyEmployeeBooleans < ActiveRecord::Migration
  def change
  	remove_column :employees, :in_saudi?
  	remove_column :employees, :permanent?
  	add_column :employees, :in_country, :boolean 
  	add_column :employees, :permanent, :boolean
  end
end
