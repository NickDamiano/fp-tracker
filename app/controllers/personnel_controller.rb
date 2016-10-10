class PersonnelController < ApplicationController
	def show
		@personnel = Employee.where(in_country: true).order(:last_name, :first_name)
	end
end
