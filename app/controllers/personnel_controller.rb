class PersonnelController < ApplicationController
	def show
		@personnel = Employee.all
	end
end
