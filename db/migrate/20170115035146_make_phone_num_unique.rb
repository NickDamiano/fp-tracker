class MakePhoneNumUnique < ActiveRecord::Migration
  def change
  	add_index :employees, :phone_num1, :unique => true
  end
end
