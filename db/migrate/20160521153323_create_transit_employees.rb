class CreateTransitEmployees < ActiveRecord::Migration
  def change
    create_table :transit_employees do |t|
      t.string :sender
      t.string :destination
      t.string :string
      t.integer :employee_id

      t.timestamps null: false
    end
  end
end
