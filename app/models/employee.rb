require 'pry-byebug'

class Employee < ActiveRecord::Base
	has_many :messages

	def self.register_employee(sender)
		# send a message to get last name
		begin
			employee = Employee.create(phone_num1: sender)
		rescue ActiveRecord::RecordNotUnique
			employee = nil
		end
		if employee 
			message = "Please send me your first name for registration"
		else
			message = "Your phone number already exists in the database"
		end
		Message.send_message(sender, message)
	end

	def self.unregister_employee(sender)
		#no confirmation needed just remove them
		Employee.find_by(phone_num1: sender).delete
		employee = Employee.find_by(phone_num1: sender)
		if employee.nil?
			message = "You have been successfully deleted from the database."
		elsif employee
			message = "There was a problem deleting you from the database."
		end
		Message.send_message(sender, message)
	end
	
	def self.parse_registration(message, sender, original_message)
		employee = Employee.find_by(phone_num1: sender)
		if original_message =~ /first/
			first_name = message # filter out bullshit
		elsif original_message =~ /last/
			last_name = message 
		elsif original_message =~ /location/
			location = message 
			# and send success message verifying first name, last name, and location
		end
	end
end
