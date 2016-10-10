class ChangeInSaudiToInCountry < ActiveRecord::Migration
  def change
  	rename_column :employees, :in_saudi, :in_country
  end
end
