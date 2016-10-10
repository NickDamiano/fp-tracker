class PersonnelController < ApplicationController
	def show
		@personnel = Employee.where(in_saudi: true).order(:last_name, :first_name)
	end
end
