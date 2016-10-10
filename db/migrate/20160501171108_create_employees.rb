class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
    	t.string :first_name
    	t.string :last_name
    	t.string :phone_num1
    	t.string :phone_num2
    	t.string :location
    	t.string :permanent?
    	t.string :in_country?
    	t.string :job_title

      t.timestamps null: false
    end
  end
end
