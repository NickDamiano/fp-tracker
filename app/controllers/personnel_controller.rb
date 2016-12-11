class PersonnelController < ApplicationController
	def show
		@personnel = Employee.where(in_country: true).order(sort_column)
	end

	private

	# Sanitize input for params to prevent SQL injection
	# If our products column name includes that parameters name
	def sort_column
		Employee.column_names.include?(params[:sort]) ? params[:sort] : "name"
	end
end
